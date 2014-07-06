
/*** Twilio ***/
// Require and initialize the Twilio module with your credentials

var ACCOUNT_SID = "AC86b279230f26f7ca6293af12e5713e9d";
var AUTH_TOKEN = "17d74223b2e0e2dff89e7b35b52eb9ac";

Parse.Cloud.define("sendVerificationCode",function(request,response){
  var code = (Math.floor(Math.random()*9000)+1000).toString();

  var user = request.user;
  user.set("phoneNumber",request.params.phoneNumber);
  user.set("phoneVerified",false);
  user.set("verifyCode",code);

  user.save().then(function(obj){
      textVerification(request.params.phoneNumber,code);
      console.log("code " + code);
      response.success("Sent verif code to "+ request.params.phoneNumber);
  },function (error) {
      response.error(error);
  });
});



var textVerification = function(phoneNumber,code){
    var client = require('twilio')(ACCOUNT_SID, AUTH_TOKEN);
    var bodyString = "Welcome to Tap Your verification code is: " + code;
    client.sendSms({
        to:phoneNumber,
        from:'+12679152630',
        body: bodyString
        }, function(err,responseData){
            if(err){
                console.log(err);
            } else{
                console.log(responseData.from);
                console.log(responseData.body);
            }
        }
    );
}



//Verify Text Code
Parse.Cloud.define("verifyCode",function(request,response){
    var code = request.params.code;
    var userT = request.user;
    userT.fetch({
        success:function(user){
            console.log("this is users code" + user.get("verifyCode") + " and this is what supplied " + code);
            if(user.get("verifyCode") === code){
                user.set("phoneVerified",true);
                user.save().then(
                    function(obj){
                        // var installation = request.params.installation;
                        // console.log("Installation: ");
                        // console.log(installation);
                        // if(installation != "0"){
                            Parse.Cloud.useMasterKey();
                            query = new Parse.Query(Parse.Installation);
                            query.equalTo("user", user);
                            query.find({
                                success:function(inst){
                                    var chan = new Array();
                                    var chanStr = "tap"+user.id;
                                    chan.push(chanStr);
                                    inst[0].set("channels",chan);
                                    // inst.set("user",user);
                                    inst[0].save().then(function(obj){
                                        response.success("true");
                                    },function(error){
                                        response.error("Failed to save installation " + error);
                                    });
                                },
                                error:function(error){
                                    response.error("Couldn't get installation with error :  " + error);
                                }
                            });
                        // }
                        // else{
                        //     response.success("true");
                        // }
                }, function ( error) {
                    response.error(error);
                });
            }
            else{
                response.success("false");
            }
        },
        error:function(error){
            response.error("here " + error);
        }
    });
 
});