const admin = require('firebase-admin');
const logger = require('../utils/logger');

let firebaseApp = null;
let firestore = null;
let auth = null;

const initialize = async () => {
  try {
    // Check if Firebase is already initialized
    if (firebaseApp) {
      logger.info('Firebase already initialized');
      return;
    }

    // Validate required environment variables
    const requiredEnvVars = [
      'FIREBASE_PROJECT_ID',
      'FIREBASE_PRIVATE_KEY_ID',
      'FIREBASE_PRIVATE_KEY',
      'FIREBASE_CLIENT_EMAIL',
      'FIREBASE_CLIENT_ID',
      'FIREBASE_AUTH_URI',
      'FIREBASE_TOKEN_URI',
      'FIREBASE_AUTH_PROVIDER_X509_CERT_URL',
      'FIREBASE_CLIENT_X509_CERT_URL'
    ];

    const missingVars = requiredEnvVars.filter(varName => !process.env[varName]);
    if (missingVars.length > 0) {
      throw new Error(`Missing required Firebase environment variables: ${missingVars.join(', ')}`);
    }

    // Initialize Firebase Admin SDK
    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        privateKeyId: process.env.FIREBASE_PRIVATE_KEY_ID,
        privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        clientId: process.env.FIREBASE_CLIENT_ID,
        authUri: process.env.FIREBASE_AUTH_URI,
        tokenUri: process.env.FIREBASE_TOKEN_URI,
        authProviderX509CertUrl: process.env.FIREBASE_AUTH_PROVIDER_X509_CERT_URL,
        clientX509CertUrl: process.env.FIREBASE_CLIENT_X509_CERT_URL
      }),
      databaseURL: `https://${process.env.FIREBASE_PROJECT_ID}.firebaseio.com`,
      storageBucket: `${process.env.FIREBASE_PROJECT_ID}.appspot.com`
    });

    // Initialize Firestore with settings
    firestore = admin.firestore();
    firestore.settings({
      ignoreUndefinedProperties: true,
      timestampsInSnapshots: true
    });
    
    // Initialize Auth
    auth = admin.auth();

    logger.info('Firebase initialized successfully');
    
  } catch (error) {
    logger.error('Failed to initialize Firebase:', error);
    throw error;
  }
};

const getFirestore = () => {
  if (!firestore) {
    throw new Error('Firebase not initialized. Call initialize() first.');
  }
  return firestore;
};

const getAuth = () => {
  if (!auth) {
    throw new Error('Firebase not initialized. Call initialize() first.');
  }
  return auth;
};

const getApp = () => {
  if (!firebaseApp) {
    throw new Error('Firebase not initialized. Call initialize() first.');
  }
  return firebaseApp;
};

const close = async () => {
  try {
    if (firebaseApp) {
      await firebaseApp.delete();
      firebaseApp = null;
      firestore = null;
      auth = null;
      logger.info('Firebase connections closed');
    }
  } catch (error) {
    logger.error('Error closing Firebase connections:', error);
  }
};

// Firestore collections
const collections = {
  MERCHANTS: 'merchants',
  SUBSCRIPTIONS: 'subscriptions',
  ADMINS: 'admins',
  APPOINTMENTS: 'appointments',
  SERVICES: 'services',
  NOTIFICATIONS: 'notifications',
  ANALYTICS: 'analytics',
  AUDIT_LOGS: 'audit_logs',
  PAYMENTS: 'payments',
  WEBHOOKS: 'webhooks'
};

// Helper functions for common Firestore operations
const createDocument = async (collection, data, id = null) => {
  try {
    const docRef = id 
      ? firestore.collection(collection).doc(id)
      : firestore.collection(collection).doc();
    
    const docData = {
      ...data,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };
    
    await docRef.set(docData);
    return { id: docRef.id, ...docData };
  } catch (error) {
    logger.error(`Error creating document in ${collection}:`, error);
    throw error;
  }
};

const updateDocument = async (collection, id, data) => {
  try {
    const docRef = firestore.collection(collection).doc(id);
    const updateData = {
      ...data,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };
    
    await docRef.update(updateData);
    return { id, ...updateData };
  } catch (error) {
    logger.error(`Error updating document in ${collection}:`, error);
    throw error;
  }
};

const deleteDocument = async (collection, id) => {
  try {
    await firestore.collection(collection).doc(id).delete();
    return { id, deleted: true };
  } catch (error) {
    logger.error(`Error deleting document in ${collection}:`, error);
    throw error;
  }
};

const getDocument = async (collection, id) => {
  try {
    const doc = await firestore.collection(collection).doc(id).get();
    if (!doc.exists) {
      return null;
    }
    return { id: doc.id, ...doc.data() };
  } catch (error) {
    logger.error(`Error getting document from ${collection}:`, error);
    throw error;
  }
};

const getDocuments = async (collection, query = null) => {
  try {
    let ref = firestore.collection(collection);
    
    if (query) {
      Object.keys(query).forEach(key => {
        ref = ref.where(key, '==', query[key]);
      });
    }
    
    const snapshot = await ref.get();
    const documents = [];
    
    snapshot.forEach(doc => {
      documents.push({ id: doc.id, ...doc.data() });
    });
    
    return documents;
  } catch (error) {
    logger.error(`Error getting documents from ${collection}:`, error);
    throw error;
  }
};

const queryDocuments = async (collection, conditions = [], orderBy = null, limit = null) => {
  try {
    let ref = firestore.collection(collection);
    
    // Apply conditions
    conditions.forEach(condition => {
      ref = ref.where(condition.field, condition.operator, condition.value);
    });
    
    // Apply ordering
    if (orderBy) {
      ref = ref.orderBy(orderBy.field, orderBy.direction || 'asc');
    }
    
    // Apply limit
    if (limit) {
      ref = ref.limit(limit);
    }
    
    const snapshot = await ref.get();
    const documents = [];
    
    snapshot.forEach(doc => {
      documents.push({ id: doc.id, ...doc.data() });
    });
    
    return documents;
  } catch (error) {
    logger.error(`Error querying documents from ${collection}:`, error);
    throw error;
  }
};

// Batch operations
const batchWrite = async (operations) => {
  try {
    const batch = firestore.batch();
    
    operations.forEach(operation => {
      const { type, collection, id, data } = operation;
      const docRef = firestore.collection(collection).doc(id);
      
      switch (type) {
        case 'create':
          batch.set(docRef, {
            ...data,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
          });
          break;
        case 'update':
          batch.update(docRef, {
            ...data,
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
          });
          break;
        case 'delete':
          batch.delete(docRef);
          break;
        default:
          throw new Error(`Invalid operation type: ${type}`);
      }
    });
    
    await batch.commit();
    logger.info(`Batch write completed: ${operations.length} operations`);
  } catch (error) {
    logger.error('Error in batch write:', error);
    throw error;
  }
};

// Transaction operations
const runTransaction = async (updateFunction) => {
  try {
    const result = await firestore.runTransaction(updateFunction);
    logger.info('Transaction completed successfully');
    return result;
  } catch (error) {
    logger.error('Error in transaction:', error);
    throw error;
  }
};

// Initialize default data
const initializeDefaultData = async () => {
  try {
    logger.info('Initializing default data in Firebase...');
    
    // Check if admin already exists
    const adminQuery = await firestore.collection(collections.ADMINS)
      .where('email', '==', 'admin@zarya.com')
      .limit(1)
      .get();
    
    if (adminQuery.empty) {
      // Create default admin
      const bcrypt = require('bcryptjs');
      const adminData = {
        email: 'admin@zarya.com',
        password: await bcrypt.hash('Admin123!', 10),
        name: 'Super Admin',
        role: 'admin',
        permissions: ['all'],
        isActive: true
      };
      
      await createDocument(collections.ADMINS, adminData);
      logger.info('Default admin created successfully');
    }
    
    logger.info('Default data initialization completed');
  } catch (error) {
    logger.error('Failed to initialize default data:', error);
    throw error;
  }
};

module.exports = {
  initialize,
  getFirestore,
  getAuth,
  getApp,
  close,
  collections,
  createDocument,
  updateDocument,
  deleteDocument,
  getDocument,
  getDocuments,
  queryDocuments,
  batchWrite,
  runTransaction,
  initializeDefaultData
};
