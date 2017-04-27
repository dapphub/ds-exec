ds-exec
===

Base contract which wraps `.call` with internals `.exec` and `.tryExec`, which handle exceptions more naturally.

```
contract DSExec {
    function tryExec( address target, bytes calldata, uint value)
             internal
             returns (bool call_ret)
    {
        return target.call.value(value)(calldata);
    }
    function exec( address target, bytes calldata, uint value)
             internal
    {
        if(!tryExec(target, calldata, value)) {
            throw;
        }
    }

    // Convenience aliases
    function exec( address t, bytes c )
        internal
    {
        exec(t, c, 0);
    }
    function exec( address t, uint256 v )
        internal
    {
        bytes memory c; exec(t, c, v);
    }
    function tryExec( address t, bytes c )
        internal
    {
        tryExec(t, c, 0);
    }
    function tryExec( address t, uint256 v )
        internal
    {
        bytes memory c; tryExec(t, c, v);
    }
}
```

