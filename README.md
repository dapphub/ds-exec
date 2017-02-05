ds-actor
===

Base contract which wraps `.call` with internals `.exec` and `.tryExec`, which handle exceptions more naturally.

```
contract DSActor {
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
}
```

Audited version in historical dappsys repo
