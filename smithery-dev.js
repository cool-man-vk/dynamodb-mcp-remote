#!/usr/bin/env node

// Helper script to run Smithery dev with .env file loaded
import { config } from 'dotenv';
import { spawn } from 'child_process';

// Load .env file
config();

console.log('Loading environment variables from .env...');
console.log(`AWS_REGION: ${process.env.AWS_REGION || 'NOT SET'}`);
console.log(`AWS_ACCESS_KEY_ID: ${process.env.AWS_ACCESS_KEY_ID ? '***' + process.env.AWS_ACCESS_KEY_ID.slice(-4) : 'NOT SET'}`);
console.log(`AWS_SECRET_ACCESS_KEY: ${process.env.AWS_SECRET_ACCESS_KEY ? '***' + process.env.AWS_SECRET_ACCESS_KEY.slice(-4) : 'NOT SET'}`);
console.log('');

// Run smithery dev with environment variables
const smithery = spawn('npx', ['smithery', 'dev'], {
  stdio: 'inherit',
  shell: true,
  env: {
    ...process.env,
  }
});

smithery.on('close', (code) => {
  process.exit(code);
});
