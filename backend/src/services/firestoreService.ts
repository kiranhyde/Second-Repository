import admin from 'firebase-admin';

const app = admin.apps.length
  ? admin.app()
  : admin.initializeApp({
      credential: admin.credential.applicationDefault(),
    });

const firestore = app.firestore();

export class FirestoreService {
  private readonly collection = firestore.collection('tasks');

  async listTasks() {
    const snapshot = await this.collection.orderBy('createdAt', 'desc').get();
    return snapshot.docs.map((doc) => doc.data());
  }

  async createTask(task: Record<string, unknown>) {
    const ref = this.collection.doc(task.id as string);
    await ref.set(task);
    return task;
  }
}
