// Quick test to verify Smithery export format
import serverFactory from './dist/index.js';

console.log('Testing Smithery export format...\n');

// Test 1: Check if default export exists
if (typeof serverFactory !== 'function') {
  console.error('❌ FAIL: Default export is not a function');
  process.exit(1);
}
console.log('✅ PASS: Default export is a function');

// Test 2: Check if it accepts config parameter
try {
  const server = serverFactory({ 
    config: {
      AWS_ACCESS_KEY_ID: 'test',
      AWS_SECRET_ACCESS_KEY: 'test',
      AWS_REGION: 'us-east-1'
    }
  });
  
  if (!server) {
    console.error('❌ FAIL: Server factory returned null/undefined');
    process.exit(1);
  }
  console.log('✅ PASS: Server factory returns a server instance');
  
  // Test 3: Check if server has expected methods
  if (typeof server.setRequestHandler !== 'function') {
    console.error('❌ FAIL: Server missing setRequestHandler method');
    process.exit(1);
  }
  console.log('✅ PASS: Server has setRequestHandler method');
  
  if (typeof server.connect !== 'function') {
    console.error('❌ FAIL: Server missing connect method');
    process.exit(1);
  }
  console.log('✅ PASS: Server has connect method');
  
  console.log('\n🎉 All tests passed! Server is ready for Smithery.');
  
} catch (error) {
  console.error('❌ FAIL: Error creating server:', error.message);
  process.exit(1);
}
