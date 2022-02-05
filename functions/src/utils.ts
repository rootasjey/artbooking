import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';

const env = functions.config();

export const allowedLicenseTypes = ["staff", "user"];

export const BASE_DOCUMENT_NAME = 'base'
export const BOOKS_COLLECTION_NAME = 'books'
export const ILLUSTRATIONS_COLLECTION_NAME = 'illustrations'
export const LICENSES_COLLECTION_NAME = 'licenses'
export const STATISTICS_COLLECTION_NAME = 'statistics'
export const USER_STATISTICS_COLLECTION_NAME = 'user_statistics'
export const ILLUSTRATION_STATISTICS_COLLECTION_NAME = 'illustration_statistics'
export const BOOK_STATISTICS_COLLECTION_NAME = 'book_statistics'
export const STORAGES_DOCUMENT_NAME = 'storages'
export const USERS_COLLECTION_NAME = 'users'

export const cloudRegions = {
  eu: 'europe-west3'
};

export async function checkUserIsSignedIn(
  context: functions.https.CallableContext,
  idToken: string,
) {
  const userAuth = context.auth;

  if (!userAuth) {
    throw new functions.https.HttpsError('unauthenticated', 'The function must be called from ' +
      'an authenticated user (2).');
  }

  let isTokenValid = false;

  try {
    await adminApp
      .auth()
      .verifyIdToken(idToken, true);

    isTokenValid = true;

  } catch (error) {
    isTokenValid = false;
  }

  if (!isTokenValid) {
    throw new functions.https.HttpsError('unauthenticated', 'Your session has expired. ' +
      'Please (sign out and) sign in again.');
  }
}

export function sendNotification(notificationData: any) {
  const headers = {
    "Content-Type": "application/json; charset=utf-8",
    Authorization: `Basic ${env.onesignal.apikey}`,
  };

  const options = {
    host: "onesignal.com",
    port: 443,
    path: "/api/v1/notifications",
    method: "POST",
    headers: headers,
  };

  const https = require("https");
  const req = https.request(options, (res: any) => {
    // console.log("statusCode:", res.statusCode);
    // console.log("headers:", res.headers);
    res.on("data", (respData: any) => {
      // console.log("Response:");
      console.log(JSON.parse(respData));
    });
  });

  req.on("error", (e: Error) => {
    console.log("ERROR:");
    console.log(e);
  });

  req.write(JSON.stringify(notificationData));
  req.end();
}

/**
 * Return a random integer between [min] and [max].
 * @param min Minimum value (included)
 * @param max Maximum value (included)
 * @returns A random integer
 */
export function randomIntFromInterval(min: number, max: number) {
  return Math.floor(Math.random() * (max - min + 1) + min)
}

/**
 * Check and return the passed value.
 * If the passed value is unknown, return a default one.
 * @param visibilityParam - Visibility value. Accepted values: acl, private, public, unlisted.
 */
export function checkOrGetDefaultVisibility(visibilityParam: string) {
  const defaultVisibility = 'private';

  const allowedVisibility = ['acl', 'private', 'public', 'unlisted'];

  if (allowedVisibility.includes(visibilityParam)) {
    return visibilityParam;
  }

  return defaultVisibility;
}
