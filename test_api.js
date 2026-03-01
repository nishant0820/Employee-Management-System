const http = require('http');

const baseURL = 'http://localhost:5000/api/auth';

async function makeRequest(path, method, data, token = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(baseURL + path);
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname,
      method: method,
      headers: {
        'Content-Type': 'application/json',
      },
    };

    if (token) {
      options.headers['Authorization'] = `Bearer ${token}`;
    }

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk.toString());
      res.on('end', () => {
        resolve({
          statusCode: res.statusCode,
          body: body ? JSON.parse(body) : null,
        });
      });
    });

    req.on('error', (err) => reject(err));

    if (data) {
      req.write(JSON.stringify(data));
    }
    req.end();
  });
}

async function runTests() {
  const email = `test_${Date.now()}@example.com`;
  const password = 'password123';
  
  console.log('1. Testing Registration...');
  const regRes = await makeRequest('/register', 'POST', {
    fullName: 'Test User',
    email: email,
    company: 'Test Corp',
    department: 'HR',
    phoneNumber: '1234567890',
    password: password,
    role: 'Recruitment and Talent Acquisition'
  });
  console.log('Register Response:', regRes.statusCode, regRes.body);

  if (regRes.statusCode !== 201) return console.error('Registration failed');

  console.log('2. Testing Login...');
  const loginRes = await makeRequest('/login', 'POST', {
    email: email,
    password: password,
    department: 'HR',
    role: 'Recruitment and Talent Acquisition'
  });
  console.log('Login Response:', loginRes.statusCode, loginRes.body);

  if (loginRes.statusCode !== 200) return console.error('Login failed');
  
  const token = loginRes.body.token;

  console.log('3. Testing GET /me...');
  const getMeRes = await makeRequest('/me', 'GET', null, token);
  console.log('GET /me Response:', getMeRes.statusCode, getMeRes.body);

  if (getMeRes.statusCode !== 200) return console.error('GET /me failed');

  console.log('4. Testing PUT /me...');
  const putMeRes = await makeRequest('/me', 'PUT', {
    fullName: 'Updated Name',
    email: email,
    phoneNumber: '0987654321',
  }, token);
  console.log('PUT /me Response:', putMeRes.statusCode, putMeRes.body);
  
  if (putMeRes.statusCode === 200 && putMeRes.body.fullName === 'Updated Name' && putMeRes.body.phoneNumber === '0987654321') {
    console.log('✅ ALL TESTS PASSED SUCCESSFULLY');
  } else {
    console.error('❌ PUT /me validation failed');
  }
}

runTests();
