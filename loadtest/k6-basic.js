// EduRim — Phase 2B basic load test (k6)
//
// Exercises the student-facing read path that every real session hits:
// health -> login -> /auth/me -> subjects -> lessons -> announcements ->
// subscription -> one static file. No write endpoints are touched (no
// register, no subscription-requests, no admin routes) — this script is
// read-only against production data.
//
// SAFETY NOTES
// - Uses ONE test account (env vars), not generated/fake accounts — do not
//   point this at real student credentials.
// - Does not create, modify, or delete any data.
// - Start at 50 VUs, then 100. Do NOT run the 300/500 stage configs
//   without explicit sign-off — see the report for why.
//
// USAGE
//   k6 run -e BASE_URL=https://edurim-api.onrender.com \
//          -e TEST_EMAIL=loadtest@example.com \
//          -e TEST_PASSWORD='********' \
//          -e STAGE=50 \
//          loadtest/k6-basic.js
//
// STAGE selects a predefined VU ramp (50 or 100). Defaults to 50 if unset.

import http from 'k6/http';
import { check, sleep, group } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8081';
const TEST_EMAIL = __ENV.TEST_EMAIL;
const TEST_PASSWORD = __ENV.TEST_PASSWORD;
// Optional: a real key under /api/files that exists on this deployment,
// e.g. "images/1700000000000000000.jpg". If unset, the file check is
// skipped instead of guessing a path that may 404 and skew failure rate.
const SAMPLE_FILE_KEY = __ENV.SAMPLE_FILE_KEY || '';
const STAGE = __ENV.STAGE || '50';

if (!TEST_EMAIL || !TEST_PASSWORD) {
  throw new Error(
    'TEST_EMAIL and TEST_PASSWORD must be set. Use a dedicated test student account — see loadtest/README.md.'
  );
}

// Two approved stages only. 300/500/1000 are intentionally not wired here —
// add them only after 50 and 100 both pass cleanly (see report, section
// "متى نوقف الاختبار").
const STAGES = {
  '50': [
    { duration: '30s', target: 10 },
    { duration: '1m', target: 50 },
    { duration: '2m', target: 50 },
    { duration: '30s', target: 0 },
  ],
  '100': [
    { duration: '30s', target: 20 },
    { duration: '1m', target: 100 },
    { duration: '2m', target: 100 },
    { duration: '30s', target: 0 },
  ],
};

if (!STAGES[STAGE]) {
  throw new Error(`Unknown STAGE "${STAGE}". Allowed values: ${Object.keys(STAGES).join(', ')}`);
}

export const options = {
  stages: STAGES[STAGE],
  thresholds: {
    http_req_duration: ['p(95)<1000'],
    http_req_failed: ['rate<0.05'],
  },
};

function authHeaders(token) {
  return { headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' } };
}

export default function () {
  group('health', function () {
    const res = http.get(`${BASE_URL}/api/health`);
    check(res, { 'health 200': (r) => r.status === 200 });
  });

  sleep(1);

  let token = '';
  group('login', function () {
    const res = http.post(
      `${BASE_URL}/api/auth/login`,
      JSON.stringify({ email: TEST_EMAIL, password: TEST_PASSWORD }),
      { headers: { 'Content-Type': 'application/json' } }
    );
    const ok = check(res, {
      'login 200': (r) => r.status === 200,
      'login has token': (r) => {
        try {
          return !!r.json('token');
        } catch (e) {
          return false;
        }
      },
    });
    if (ok) {
      token = res.json('token');
    }
  });

  if (!token) {
    // Without a token every protected call below would just fail and
    // pollute the failure rate with a misleading signal — stop this
    // iteration cleanly instead.
    sleep(2);
    return;
  }

  sleep(1);

  group('auth_me', function () {
    const res = http.get(`${BASE_URL}/api/auth/me`, authHeaders(token));
    check(res, { 'auth/me 200': (r) => r.status === 200 });
  });

  sleep(1);

  group('me_subjects', function () {
    const res = http.get(`${BASE_URL}/api/me/subjects`, authHeaders(token));
    check(res, { 'me/subjects 200': (r) => r.status === 200 });
  });

  sleep(1);

  group('me_lessons', function () {
    const res = http.get(`${BASE_URL}/api/me/lessons`, authHeaders(token));
    check(res, { 'me/lessons 200': (r) => r.status === 200 });
  });

  sleep(1);

  group('me_announcements', function () {
    const res = http.get(`${BASE_URL}/api/me/announcements`, authHeaders(token));
    check(res, { 'me/announcements 200': (r) => r.status === 200 });
  });

  sleep(1);

  group('me_subscription', function () {
    const res = http.get(`${BASE_URL}/api/me/subscription`, authHeaders(token));
    check(res, { 'me/subscription 200': (r) => r.status === 200 });
  });

  if (SAMPLE_FILE_KEY) {
    sleep(1);
    group('sample_file', function () {
      const res = http.get(`${BASE_URL}/api/files/${SAMPLE_FILE_KEY}`);
      check(res, { 'file 200': (r) => r.status === 200 });
    });
  }

  sleep(2);
}
