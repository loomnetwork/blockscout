#!/usr/bin/env node

var sourceCode = process.argv[2];
var version = process.argv[3];
var optimize = process.argv[4];
var optimizationRuns = parseInt(process.argv[5], 10);
var newContractName = process.argv[6];
var externalLibraries = JSON.parse(process.argv[7])
var evmVersion = process.argv[8];
var compilerVersionPath = process.argv[9];

var solc = require('solc')
var compilerSnapshot = require(compilerVersionPath);
var solc = solc.setupMethods(compilerSnapshot);

const input = {
  language: 'Solidity',
  sources: {
    [newContractName]: {
      content: sourceCode
    }
  },
  settings: {
    evmVersion: evmVersion,
    optimizer: {
      enabled: optimize == '1',
      runs: optimizationRuns
    },
    libraries: {
      [newContractName]: externalLibraries
    },
    outputSelection: {
      '*': {
        '*': ['*']
      }
    }
  }
}


const output = JSON.parse(solc.compile(JSON.stringify(input)))
console.log(JSON.stringify(output));
