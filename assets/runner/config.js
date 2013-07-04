// 'var' must be used here, else PhantomJS throws RangeError
var should;

(function() {
  require.config(window.MIMOSA_TEST_REQUIRE_CONFIG);
  require(['testem-require/mocha',
           'testem-require/chai',
           'testem-require/sinon',
           'testem-require/sinon-chai'],
    function(mocha, chai, sinon, sinonChai){
      require(['../testem'], function(){
        assert = chai.assert;
        expect = chai.expect;
        should = chai.should();
        chai.Assertion.includeStack = true;
        chai.use(sinonChai);

        mocha.setup(window.MIMOSA_TEST_MOCHA_SETUP);

        require(window.MIMOSA_TEST_SPECS, function(module){
          mocha.run();
        });
      });
    }
  );
}).call(this);
