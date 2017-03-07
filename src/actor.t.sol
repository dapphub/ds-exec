pragma solidity ^0.4.8;

import "ds-test/test.sol";
import './actor.sol';

// Simple example and passthrough for testing
contract DSSimpleActor is DSActor {
    function execute(address target, bytes calldata, uint value)
    {
        exec(target, calldata, value);
    }
    function tryExecute(address target, bytes calldata, uint value)
             returns (bool call_ret)
    {
        return tryExec(target, calldata, value);
    }

    function() payable {}
}


// Test helper: record calldata from fallback and compare.
contract CallReceiver {
    bytes last_calldata;
    uint last_value;
    function compareLastCalldata( bytes data ) returns (bool) {
        // last_calldata.length might be longer because calldata is padded
        // to be a multiple of the word size
        if( data.length > last_calldata.length ) {
            return false;
        }
        for( var i = 0; i < data.length; i++ ) {
            if( data[i] != last_calldata[i] ) {
                return false;
            }
        }
        return true;
    }
    function() payable {
        last_calldata = msg.data;
        last_value = msg.value;
    }
}

// actually tests "SimpleActorTest"
contract DSActorTest is DSTest {
    bytes calldata;
    DSSimpleActor a;
    CallReceiver cr;
    function setUp() {
        assert(this.balance > 0);
        
        a = new DSSimpleActor();
        if (!a.send(10 wei)) throw;

        cr = new CallReceiver();
    }
    function testProxyCall() {
        for(var i = 0; i < 35; i++) {
            calldata.push(byte(i));
        }
        a.execute(address(cr), calldata, 0);
        assert(cr.compareLastCalldata(calldata));
    }
    function testTryProxyCall() {
        for(var i = 0; i < 35; i++) {
            calldata.push(byte(i));
        }
        assert(a.tryExecute(address(cr), calldata, 0));
        assert(cr.compareLastCalldata(calldata));
    }
    function testProxyCallWithValue() {
        assertEq(cr.balance, 0);

        for( var i = 0; i < 35; i++ ) {
            calldata.push(byte(i));
        }
        assertEq(a.balance, 10 wei);
        a.execute(address(cr), calldata, 10 wei);
        assert(cr.compareLastCalldata(calldata));
        assertEq(cr.balance, 10 wei);
    }
    function testTryProxyCallWithValue() {
        assertEq(cr.balance, 0);

        for( var i = 0; i < 35; i++ ) {
            calldata.push(byte(i));
        }
        assertEq(a.balance, 10 wei);
        assert(a.tryExecute(address(cr), calldata, 10 wei));
        assert(cr.compareLastCalldata(calldata));
        assertEq(cr.balance, 10 wei);
    }
}
