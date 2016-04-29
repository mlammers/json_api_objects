    function Resource(use_native_getter) {
      this._use_native_getter = use_native_getter||true;
    }

    // Statische function

    /**
    * Converts a param object into a parameter string of type "param_name[key]=obj[key]&..."
    * @param param_name The paramater name
    * @param obj the Parameter object
    * @returns The parameter string
    */
    Resource.object2params = function(param_name, obj) {
    var params = [];
    for (var key in obj) {
      params.push(param_name + '[' + key + ']=' + Experteer.URI.fullescape(obj[key]));
    }
    return params.join('&');
    };


    /**
    * Type helper Functions
    **/
    Resource.typeof = function(object) {
    return {}.toString.call(object);
    };

    Resource.isFunction = function(object) {
    return Resource.typeof(object) == "[object Function]";
    };

    Resource.isArray = function(object) {
    return Resource.typeof(object) == "[object Array]";
    };

    Resource.isObject = function(object) {
    return Resource.typeof(object) == "[object Object]";
    };

    Resource.isNull = function(object) {
    return Resource.typeof(object) == "[object Null]";
    };

    Resource.isUndefined = function(object) {
    return Resource.typeof(object) == "[object Undefined]";
    };

    Resource.isNumber = function(object) {
    return Resource.typeof(object) == "[object Number]";
    };

    Resource.isString = function(object) {
    return Resource.typeof(object) == "[object String]";
    };

    Resource.is = function(object, type) {
    return object instanceof type;
    };

    Resource.getFunctionName = function (fn) {
    return (fn + '').split(/\s|\(/)[1];
    };

    Resource.FunctionCreator = function(fdata) {
    var func = null;
    if (fdata && Resource.isString(fdata) && fdata != "") eval("func = "+fdata);
    return func;
    };

    /**
    * Create a Resource:
    * @param type The type of the new object: function, String, Array with one string or function
    * @param data The data to pass to the constructor
    * @returns The newly created Object or array of objects
    **/
    Resource.create_resource = function(type, data, parent) {
    if (Resource.isFunction(type)) {
      // Logger.info("create_resource: "+Resource.getFunctionName(type));
      if (data == null) return null;
      var resource = new type(data, parent);
      if (Resource.isFunction(resource.initialize)) resource.initialize(data, parent);
      return resource;
    } else if (Resource.isString(type)) {
      type = Resource.parse_json(type);
      if (Resource.isString(type)) {
        // Logger.info("create_resource: "+type);
        if (data == null) return null;
        constructor = eval(type);
        var resource = new constructor(data, parent);
        if (Resource.isFunction(resource.initialize)) resource.initialize(data, parent);
        return resource;
      } else {
        return Resource.create_resource(type, data, parent);
      }
    } else if (Resource.isArray(type)) {
      // Logger.info("create_resource Array of: "+(Resource.isString(type[0])?type[0]:Resource.getFunctionName(type[0])));
      var result_array = [];
      if (data == null) return result_array;
      if (Resource.isString(data)) data = Resource.parse_json(data);
      if (Resource.isArray(data)) {
        for (var index=0;index<data.length;index++) {
          result_array.push(Resource.create_resource(type[0], data[index], parent));
        }
      } else {
        result_array.push(Resource.create_resource(type[0], data, parent));
      }
      return result_array;
    }
    };

    /**
    * Parse json safely
    * @param data The string to parse
    * @returns The parsed json object or a string on failure
    **/
    Resource.parse_json = function(data) {
    if (typeof data == "string") {
      try {
        // Logger.info("Parsing json failed!");
        return JSON.parse(data);
      } catch(e) {
        // Logger.info("Parsing json failed!");
        return data;
      }
    }
    // Logger.info("Parsing json not needed!");
    return data;
    };

    Resource.value_name = function(property) {
    return "_"+property;
    };
    Resource.value_func_name = function(property) {
    return property;
    };

    Resource.generate_setter_getter = function(o, property, type) {
    if (Resource.isFunction(o[Resource.value_func_name(property)])) return;

    if (o._use_native_getter) {
      Object.defineProperty(o, Resource.value_func_name(property), {
        get : function() {
          return this[Resource.value_name(property)];
        },
        set: function(param) {
          if (type) {
            if (Resource.is(param, Resource) || (Resource.isArray(param) && Resource.is(param[0], Resource))) {
              this[Resource.value_name(property)] = param;
            }
            else {
              this[Resource.value_name(property)] = Resource.create_resource(type, param, this)
            }
          } else
            this[Resource.value_name(property)] = param;
        },
        configurable: true
      });
    } else {
      o[Resource.value_func_name(property)] = function(param) {
        if (param) {
          if (type) {
            if (Resource.is(param, Resource) || (Resource.isArray(param) && Resource.is(param[0], Resource))) {
              o[Resource.value_name(property)] = param;
            }
            else {
              o[Resource.value_name(property)] = Resource.create_resource(type, param, o)
            }
          } else
            o[Resource.value_name(property)] = param;
          return o;
        }
        else {
          return o[Resource.value_name(property)];
        }
      };
    }
    };

    /**
    * Loads data from an json object into another one
    * @param object The object to fill with data
    * @param data The data to put into the object
    * @param only_defined Tells the loader if only variables already present in object or config should be loaded
    * @param config Allows the loader to call special constructors for variables during load time
    **/
    Resource.load_data = function(object, data, only_defined, config) {
    if (config && Resource.isFunction(config))
      config = config(object);
    data = Resource.parse_json(data);

    var basic_serialize = {};

    for (var name in object) {
      if (!Resource.isFunction(object[name]) && name[0] != "_" && name != "strict_defined" && name != "property_defines" && name != "parent") basic_serialize[name] = false;
      // console.log("Generate for: "+name)
      if (!Resource.isFunction(object[Resource.value_func_name(name)]) && name[0] != "_" && name != "strict_defined" && name != "property_defines") {
        object[Resource.value_name(name)] = object[Resource.value_func_name(name)];
        Resource.generate_setter_getter(object, name, config[name]);
      }
    }
    if (Resource.isObject(data)) {
      for (var name in data) {
        if (!Resource.isUndefined(object[name]) || !only_defined || !Resource.isUndefined(config[name])) {
          if (!Resource.isFunction(object[name]) && name[0] != "_" && name != "strict_defined" && name != "property_defines" && name != "parent") basic_serialize[name] = false;
          if (config && !Resource.isUndefined(config[name]) && !Resource.is(data[name], Resource) && (Resource.isFunction(config[name]) || Resource.isArray(config[name]) || Resource.isString(config[name]))) {
            object[Resource.value_name(name)] = Resource.create_resource(config[name], data[name], object);
          }
          else {
            object[Resource.value_name(name)] = data[name];
          }
          Resource.generate_setter_getter(object, name, config[name]);
        }
      }
    }

    for (var name in config) {
      basic_serialize[name] = true;
      Resource.generate_setter_getter(object, name, config[name]);
    }

    object._basic_serialize = object._basic_serialize||{};
    for (var name in basic_serialize) {
      if (!object._basic_serialize[name]) object._basic_serialize[name] = basic_serialize[name];
    }
    };

    /**
    * Serializes the object
    **/
    Resource.prototype.serialize = function(config) {
    var serialized = {};
    var serialized_config = config||this._basic_serialize||{}
    for (var name in serialized_config) {
      if (serialized_config[name] == false) {
        serialized[name] = this[Resource.value_name(name)];
      } else if (Resource.isFunction(serialized_config[name])) {
        serialized[name] = serialized_config[name](this, this[Resource.value_name(name)]);
      } else {
        if (this[Resource.value_name(name)] && !Resource.isFunction(this[Resource.value_name(name)]))
          if (Resource.isArray(this[Resource.value_name(name)])) {
            serialized[name] = [];
            for (var idx in this[Resource.value_name(name)]) {
              // Logger.log("Trying to serialize: "+Resource.value_name(name)+"["+idx+"]");
              if (Resource.isFunction(this[Resource.value_name(name)][idx].serialize))
                serialized[name][idx] = this[Resource.value_name(name)][idx].serialize();
              else
                serialized[name][idx] = this[Resource.value_name(name)][idx];
            }
          }
          else {
            // Logger.log("Trying to serialize: "+Resource.value_name(name));
            if (Resource.isFunction(this[Resource.value_name(name)].serialize))
              serialized[name] = this[Resource.value_name(name)].serialize();
            else
              serialized[name] = this[Resource.value_name(name)];
          }
        else
          serialized[name] = null;
      }
    }
    return serialized;
    };

    /**
    * Loads the object itself
    */
    Resource.prototype.initialize = function(data, parent) {
    if (parent) this.parent = parent;
    Resource.load_data(this, data, this.strict_defined, this.property_defines||{});
    return this;
    };

    return Resource;
