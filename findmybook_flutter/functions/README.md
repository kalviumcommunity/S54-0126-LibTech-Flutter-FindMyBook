# Cloud Functions for FindMyBook

This folder contains a small Firebase Cloud Function set that keeps `books.available` in sync with the `loans` collection.

Deploy with:

```
cd functions
npm install
firebase deploy --only functions
```
