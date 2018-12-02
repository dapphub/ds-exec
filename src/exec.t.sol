// exec.t.sol - test for exec.sol

// Copyright (C) 2017  DappHub, LLC

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity >=0.4.23;

import "ds-test/test.sol";
import './exec.sol';

// Simple example and passthrough for testing
contract DSSimpleActor is DSExec {
    function execute(address target, bytes memory data, uint value)
        public
    {
        exec(target, data, value);
    }
    function tryExecute(address target, bytes memory data, uint value)
        public
        returns (bool call_ret)
    {
        return tryExec(target, data, value);
    }

    function() external payable {}
}


// Test helper: record calldata from fallback and compare.
contract CallReceiver {
    bytes last_calldata;
    uint last_value;
    function compareLastCalldata(bytes memory data) public view returns (bool) {
        // last_calldata.length might be longer because calldata is padded
        // to be a multiple of the word size
        if( data.length > last_calldata.length ) {
            return false;
        }
        for (uint i = 0; i < data.length; i++) {
            if( data[i] != last_calldata[i] ) {
                return false;
            }
        }
        return true;
    }
    function() external payable {
        last_calldata = msg.data;
        last_value = msg.value;
    }
}

// actually tests "DSSimpleActor"
contract DSExecTest is DSTest {
    bytes data;
    DSSimpleActor a;
    CallReceiver cr;
    function setUp() public {
        assert(address(this).balance > 0);
        
        a = new DSSimpleActor();
        if (!address(a).send(10 wei)) revert();

        cr = new CallReceiver();
    }
    function testProxyCall() public {
        for (uint i = 0; i < 35; i++) {
            data.push(byte(uint8(i)));
        }
        a.execute(address(cr), data, 0);
        assertTrue(cr.compareLastCalldata(data));
    }
    function testTryProxyCall() public {
        for (uint i = 0; i < 35; i++) {
            data.push(byte(uint8(i)));
        }
        assertTrue(a.tryExecute(address(cr), data, 0));
        assertTrue(cr.compareLastCalldata(data));
    }
    function testProxyCallWithValue() public {
        assertEq(address(cr).balance, 0);

        for (uint i = 0; i < 35; i++ ) {
            data.push(byte(uint8(i)));
        }
        assertEq(address(a).balance, 10 wei);
        a.execute(address(cr), data, 10 wei);
        assertTrue(cr.compareLastCalldata(data));
        assertEq(address(cr).balance, 10 wei);
    }
    function testTryProxyCallWithValue() public {
        assertEq(address(cr).balance, 0);

        for (uint i = 0; i < 35; i++ ) {
            data.push(byte(uint8(i)));
        }
        assertEq(address(a).balance, 10 wei);
        assertTrue(a.tryExecute(address(cr), data, 10 wei));
        assertTrue(cr.compareLastCalldata(data));
        assertEq(address(cr).balance, 10 wei);
    }
}
