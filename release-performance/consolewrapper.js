var newConsole = (function(oldConsole)
{
    return {
        __logHistory : [],
        log : function()
        {
            var data = [];
            for (var _i = 0; _i < arguments.length; _i++) {
                data[_i] = arguments[_i];
            }
            this.__logHistory.push(data[0]);
            if(data.length == 1) //Start looking for api's (And dont show anything)
            {
                if(typeof(data[0]) == "string" && data[0].indexOf("callJavascriptFunction") != -1) //Contains function
                {
                    eval(data[0].split("callJavascriptFunction ")[1]);
                }
                else
                    oldConsole.log(data[0]);
            }
            else
                oldConsole.log(data[0], data.splice(1));
        },
        warn : function()
        {
            var data = [];
            for (var _i = 0; _i < arguments.length; _i++) {
                data[_i] = arguments[_i];
            }
            this.__logHistory.push(data[0]);
            if(data.length == 1)
                oldConsole.warn(data[0]);
            else
                oldConsole.warn(data[0], data.splice(1));
        },
        error : function()
        {
            var data = [];
            for (var _i = 0; _i < arguments.length; _i++) {
                data[_i] = arguments[_i];
            }
            this.__logHistory.push(data[0]);
            if(data.length == 1)
                oldConsole.error(data[0]);
            else
                oldConsole.error(data[0], data.splice(1));
        },
        clear : function()
        {
            oldConsole.clear()
        },
        assert : function()
        {
            for (var _i = 0; _i < arguments.length; _i++) {
                data[_i] = arguments[_i];
            }
            oldConsole.assert(data[0], data[1], data.splice(2));
        },
        group : function()
        {
            for (var _i = 0; _i < arguments.length; _i++) {
                data[_i] = arguments[_i];
            }
            oldConsole.group(data[0], data.splice(1));
        },
        groupCollapsed : function()
        {
            for (var _i = 0; _i < arguments.length; _i++) {
                data[_i] = arguments[_i];
            }
            oldConsole.groupCollapsed(data[0], data.splice(1));
        },
        groupEnd : function()
        {
            oldConsole.groupEnd()
        }
    }
}(window.console));
window.console = newConsole;