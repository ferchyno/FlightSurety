
var Test = require('../config/testConfig.js');
var BigNumber = require('bignumber.js');

/**
  Available Accounts
 ==================
 (0) 0x627306090abaB3A6e1400e9345bC60c78a8BEf57 (100 ETH) // Owner
 (1) 0xf17f52151EbEF6C7334FAD080c5704D77216b732 (100 ETH) // Airline 1
 (2) 0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef (100 ETH)
 (3) 0x821aEa9a577a9b44299B9c15c88cf3087F3b5544 (100 ETH)
 (4) 0x0d1d4e623D10F9FBA5Db95830F7d3839406C6AF2 (100 ETH)
 (5) 0x2932b7A2355D6fecc4b5c0B6BD44cC31df247a2e (100 ETH)
 (6) 0x2191eF87E392377ec08E7c08Eb105Ef5448eCED5 (100 ETH)
 (7) 0x0F4F2Ac550A1b4e2280d04c21cEa7EBD822934b5 (100 ETH)
 (8) 0x6330A553Fc93768F612722BB8c2eC78aC90B3bbc (100 ETH)
 (9) 0x5AEDA56215b167893e80B4fE645BA6d5Bab767DE (100 ETH)
 (10) 0xE44c4cf797505AF1527B11e4F4c6f95531b4Be24 (100 ETH)
 (11) 0x69e1CB5cFcA8A311586e3406ed0301C06fb839a2 (100 ETH)
 (12) 0xF014343BDFFbED8660A9d8721deC985126f189F3 (100 ETH)
 (13) 0x0E79EDbD6A727CfeE09A2b1d0A59F7752d5bf7C9 (100 ETH)
 (14) 0x9bC1169Ca09555bf2721A5C9eC6D69c8073bfeB4 (100 ETH)
 (15) 0xa23eAEf02F9E0338EEcDa8Fdd0A73aDD781b2A86 (100 ETH)
 (16) 0xc449a27B106BE1120Bd1Fd62F8166A2F61588eb9 (100 ETH)
 (17) 0xF24AE9CE9B62d83059BD849b9F36d3f4792F5081 (100 ETH)
 (18) 0xc44B027a94913FB515B19F04CAf515e74AE24FD6 (100 ETH)
 (19) 0xcb0236B37Ff19001633E38808bd124b60B1fE1ba (100 ETH)
 (20) 0x715e632C0FE0d07D02fC3d2Cf630d11e1A45C522 (100 ETH)
 (21) 0x90FFD070a8333ACB4Ac1b8EBa59a77f9f1001819 (100 ETH)
 (22) 0x036945CD50df76077cb2D6CF5293B32252BCe247 (100 ETH)
 (23) 0x23f0227FB09D50477331D2BB8519A38a52B9dFAF (100 ETH)
 (24) 0x799759c45265B96cac16b88A7084C068d38aFce9 (100 ETH)
 (25) 0xA6BFE07B18Df9E42F0086D2FCe9334B701868314 (100 ETH)
 (26) 0x39Ae04B556bbdD73123Bab2d091DCD068144361F (100 ETH)
 (27) 0x068729ec4f46330d9Af83f2f5AF1B155d957BD42 (100 ETH)
 (28) 0x9EE19563Df46208d4C1a11c9171216012E9ba2D0 (100 ETH)
 (29) 0x04ab41d3d5147c5d2BdC3BcFC5e62539fd7e428B (100 ETH)
 (30) 0xeF264a86495fF640481D7AC16200A623c92D1E37 (100 ETH)
 (31) 0x645FdC97c87c437da6b11b72471a703dF3702813 (100 ETH)
 (32) 0xbE6f5bF50087332024634d028eCF896C7b482Ab1 (100 ETH)
 (33) 0xcE527c7372B73C77F3A349bfBce74a6F5D800d8E (100 ETH)
 (34) 0x21ec0514bfFefF9E0EE317b8c87657E4a30F4Fb2 (100 ETH)
 (35) 0xEAA2fc390D0eC1d047dCC1210a9Bf643d12de330 (100 ETH)
 (36) 0xC5fa34ECBaF44181f1d144C13FBaEd69e76b80f1 (100 ETH)
 (37) 0x4F388EE383f1634d952a5Ed8e032Dc27094f44FD (100 ETH)
 (38) 0xeEf5E3535aA39e0C2266BbA234E187adA9ed50A1 (100 ETH)
 (39) 0x6008E128477ceEE5561fE2dEAdD82564d29fD249 (100 ETH)
 (40) 0xfEf504C230aA4c42707FcBFfa46aE640498BC2cb (100 ETH)
 (41) 0x70C8F02D4e44d906e80a8d0b1591Ab569a20Ae9C (100 ETH)
 (42) 0x53eF3e89950e97bAD7d027F41ab05debc7Bb5c74 (100 ETH)
 (43) 0xE3c27A49b81a7D59DC516D58ab2E5ee6A545c008 (100 ETH)
 (44) 0xc496E6FEACf5D7ee4E1609179fA4C1D1698116ec (100 ETH)
 (45) 0x5598CA13044003326C25459B4E9B778922C8a00e (100 ETH)
 (46) 0x5Fb25C1c734D077fdFb603E9f586Bee11706a042 (100 ETH)
 (47) 0x3E5a0f348C831b489deC1be087f8Ef182A4CfE54 (100 ETH)
 (48) 0x6a90Ed741Fe4B87545a127879bA18F41FD17fdB5 (100 ETH)
 (49) 0xa1AD47355B994Cc18Bd709789055DeFD54e738E3 (100 ETH)

 Private Keys
 ==================
 (0) 0xc87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3
 (1) 0xae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f
 (2) 0x0dbbe8e4ae425a6d2687f1a7e3ba17bc98c673636790f1b8ad91193c05875ef1
 (3) 0xc88b703fb08cbea894b6aeff5a544fb92e78a18e19814cd85da83b71f772aa6c
 (4) 0x388c684f0ba1ef5017716adb5d21a053ea8e90277d0868337519f97bede61418
 (5) 0x659cbb0e2411a44db63778987b1e22153c086a95eb6b18bdf89de078917abc63
 (6) 0x82d052c865f5763aad42add438569276c00d3d88a2d062d36b2bae914d58b8c8
 (7) 0xaa3680d5d48a8283413f7a108367c7299ca73f553735860a87b08f39395618b7
 (8) 0x0f62d96d6675f32685bbdb8ac13cda7c23436f63efbb9d07700d8669ff12b7c4
 (9) 0x8d5366123cb560bb606379f90a0bfd4769eecc0557f1b362dcae9012b548b1e5
 (10) 0xdbb9d19637018267268dfc2cc7aec07e7217c1a2d6733e1184a0909273bf078b
 (11) 0xaa2c70c4b85a09be514292d04b27bbb0cc3f86d306d58fe87743d10a095ada07
 (12) 0x3087d8decc5f951f19a442397cf1eba1e2b064e68650c346502780b56454c6e2
 (13) 0x6125c8d4330941944cc6cc3e775e8620c479a5901ad627e6e734c6a6f7377428
 (14) 0x1c3e5453c0f9aa74a8eb0216310b2b013f017813a648fce364bf41dbc0b37647
 (15) 0xea9fe9fd2f1761fc6f1f0f23eb4d4141d7b05f2b95a1b7a9912cd97bddd9036c
 (16) 0xfde045729ba416689965fc4f6d3f5c8de6f40112d2664ab2212208a17842c5c9
 (17) 0xd714e4a16a539315abb2d86401e4ceae3cf901849769345e3ab64ee46d998b64
 (18) 0x737f5c61de545d32059ce6d5bc72f7d34b9963310adde62ef0f26621266b65dc
 (19) 0x49b2e2b48cfc25fda1d1cbdb2197b83902142c6da502dcf1871c628ea524f11b
 (20) 0xa7d6fac8e19a1e40913ef3a0e9962ae68e37f570dfa3966451cdf9a8c2f87bfb
 (21) 0x6aed47a7a3e429695846acdecf3d355911525be5e8725505cfed5b581b2b451c
 (22) 0x9622756233475771eab3b48889319c7deca6a19df2aafac43209983f6f0d6811
 (23) 0x13d8966a34514bd9823870d3a6ba8b166014d903374d02d5a5d50be9e3db332d
 (24) 0xcb2b041a92457c84e4d31ad2442e9da7d61ad890495e5d3b196598eb3fbdf641
 (25) 0x44f85820332a35e531000f48d059286efb2e63b3f7257ecb32450600b5c9eef8
 (26) 0x6e2f896268d56c476f2994dbdcc254960e5c60b151f587f7f13b62dfbed89740
 (27) 0xcc4d05ee4317a9bd0dfa09be019fecf906ca9612c42665c5d48b7d4ef9f79f99
 (28) 0xcab59c61d7eb7c3ea7b47fc69c8df0100b6bd4c6a20304114444c1f1d8d373c0
 (29) 0xf559e660678c33c77fd44a7a9afe18a1cb1a6607a2e516e407be0637a2a7313d
 (30) 0x6c4d00fdc815d9514815cfa490c6a09598088a907407689bbb0a25fad2954936
 (31) 0x1dfe78df80fcace578ed59cb01213e85e8efcbef47b00a6b3c92ff422ad1f664
 (32) 0xb5e6fec3bf25405fc64d93c96f5268c2c22c4f2d193a142731deca8f5dfdc4e3
 (33) 0x874516d97cc55d88d065a0623e24126906e875480336702c710d0ca7cc146bf6
 (34) 0x19501ed7b22215ed3a0c356bb6121533215b33cee85616cd9458a8f41057adaf
 (35) 0x39ebfb625fd5641de5b98b3bc8cb05e024a5ec6c356ba13ebee2d763f87e72fe
 (36) 0x911448be9fb3038e8e740189de91917e149222e236c17226b623cbad400e9295
 (37) 0xe759db8c0ab657e602269ddf8dfaefd2a79e000f684ba2e3e0e53668a2e1a841
 (38) 0x051b84c8029bc4d095ae874ca120181a1527c3a2d6f40abd445ed78a97d1db55
 (39) 0x82c1fb29d4b4265b95ddf0aefdc78c85c399c3d944f859abf06f68e29d1803dd
 (40) 0x4fbc2d83e056f04f5f0af8d9f68440d01247cc8df2bd977f5314c05b92cf6eda
 (41) 0xc99f998bf5274033c67a281ab5be6ecf6e1a5a6a4874798454c56c98516b4a0c
 (42) 0xd50a901d34d09a6401b4799f5236d65faaf2432d1c0c7776061ed167374870f2
 (43) 0xc3d23d9462d1868f5e97af0c9bab877517a3f9097d90ad3a130c6d8f3091fcaf
 (44) 0xcd51015340bc83d406f9166f5a1f7ab529017e8d3e0b3956f2cee2a0160e020c
 (45) 0xb2b0808f1701b2f94c9cbf114b12ca5d712ab5b5d3f5d4958446ff28f259d9f8
 (46) 0x0101610889163a9438008ddf56a3dc16e4af5d9bf3be845bbcd0428a6738b9e0
 (47) 0x4ceab82cac96b636bf035c3bbaae312314aad8712ba3d779d68a39a8ce6294b4
 (48) 0x38d1ae9f9c4ebc663c76cbd8ae3c542f18c10331f9b0638a2763766c21e5cdb6
 (49) 0x3fc4e28e8504e54280e1b6fd551b14cd0f819da2756e1e0c87d8e5a3e5081477
 */

contract('Flight Surety Tests', async (accounts) => {

  var config;
  before('setup contract', async () => {
    config = await Test.Config(accounts);
    await config.flightSuretyData.authorizeCaller(config.flightSuretyApp.address);
  });

  /****************************************************************************************/
  /* Operations and Settings                                                              */
  /****************************************************************************************/

  it(`(multiparty) has correct initial isOperational() value`, async function () {

    // Get operating status
    let status = await config.flightSuretyData.isOperational.call();
    assert.equal(status, true, "Incorrect initial operating status value");

  });

  it(`(multiparty) can block access to setOperatingStatus() for non-Contract Owner account`, async function () {

      // Ensure that access is denied for non-Contract Owner account
      let accessDenied = false;
      try 
      {
          await config.flightSuretyData.setOperatingStatus(false, { from: config.testAddresses[2] });
      }
      catch(e) {
          accessDenied = true;
      }
      assert.equal(accessDenied, true, "Access not restricted to Contract Owner");
            
  });

  it(`(multiparty) can allow access to setOperatingStatus() for Contract Owner account`, async function () {

      // Ensure that access is allowed for Contract Owner account
      let accessDenied = false;
      try 
      {
          await config.flightSuretyData.setOperatingStatus(false);
      }
      catch(e) {
          accessDenied = true;
      }
      assert.equal(accessDenied, false, "Access not restricted to Contract Owner");
      
  });

  it(`(multiparty) can block access to functions using requireIsOperational when operating status is false`, async function () {

      await config.flightSuretyData.setOperatingStatus(false);

      let reverted = false;
      try 
      {
          await config.flightSurety.setTestingMode(true);
      }
      catch(e) {
          reverted = true;
      }
      assert.equal(reverted, true, "Access not blocked for requireIsOperational");      

      // Set it back for other tests to work
      await config.flightSuretyData.setOperatingStatus(true);

  });

  it('(airline) cannot register an Airline using registerAirline() if it is not funded', async () => {
    
    // ARRANGE
    let newAirline = accounts[2];

    // ACT
    try {
        await config.flightSuretyApp.registerAirline(newAirline, {from: config.firstAirline});
    }
    catch(e) {

    }
    let result = await config.flightSuretyData.isAirline.call(newAirline); 

    // ASSERT
    assert.equal(result, false, "Airline should not be able to register another airline if it hasn't provided funding");

  });
 

});
