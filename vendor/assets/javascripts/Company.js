angular.module('models')
  .factory('Company', function (Resource){

      /**
       * Company Constructor
       */
      Company.prototype = new Resource();
      Company.prototype.constructor = Company;
      Company.prototype.strict_defined = true;
      Company.prototype.property_defines = {

      };

      function Company() {
        this.id = null;
        this.name = null;
        this.description = null;
        this.company_aliases = null;
        this.company_tree = null;
        this.main_industry = null;
        this.main_geocode = null;
        this.notes = {
          standard: null,
          legal: null
        };
        this.url = null;
        this.career_url = null;
      };

      Company.prototype.addToAliases = function(alias) {
        this._company_aliases.push(alias);
      }

      return Company;
  })
