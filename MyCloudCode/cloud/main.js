
/*** Twilio ***/
// Require and initialize the Twilio module with your credentials

var ACCOUNT_SID = "AC86b279230f26f7ca6293af12e5713e9d";
var AUTH_TOKEN = "17d74223b2e0e2dff89e7b35b52eb9ac";

Array.prototype.contains = function(obj) {
    var i = this.length;
    while (i--) {
        if (this[i] === obj) {
            return true;
        }
    }
    return false;
}


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

var getContactNameFromObjectId = function(senderObejectId, recipientObjId, callback) {
    console.log("getContactNameFromObjectId");
    // console.log ("senderObejectId " + senderObejectId);
    // console.log ("recipientObjId " + recipientObjId);

    Parse.Cloud.useMasterKey();
    query = new Parse.Query (Parse.User);
    query.get(recipientObjId, {
      success: function(object) {
        console.log("success");
        console.log(object);
        var friendsArray = object.friendsArray;
        console.log("friendsArray: ");
        console.log(friendsArray);
        for (var i = 0; i < friendsArray.length; i++) {
            var friend = friendsArray[i];
            if (friend.id === senderObejectId) {
                callback(friend.username);
            }
        }
      },

      error: function(object, error) {
        console.log("error");
        console.log(error);
        // error is an instance of Parse.Error.
      }
    });

}

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



Parse.Cloud.define("sendSprayPushNotifications", function(request, response) {
    console.log("spray before save request");
    // console.log(request);
    var subscribersArray = request.params.recipients;
    
    if (subscribersArray.length < 1) {
        response.error("No recipients");
    } else {
        var username = request.user.get("username");

        for (var i = 0; i < subscribersArray.length; i++) {
            var recipient = subscribersArray[i];
            // var recipientUser = recipient.fetch();
            var id = recipient;
            if (id === request.user.id) continue;
            var channel = "tap" + id;
            // getContactNameFromObjectId(request.user.id ,id, function(name) {
            
            sendNewTapPush(channel, "From " + username);
            
        }
        response.success();   
    }
});





var sendNewTapPush = function(channel, alert) {
    Parse.Push.send({
        channels: [channel],
        data: {
            "alert": alert,
            "sound": "default",
            "badge": "Increment",
            "type":"newtap",//,
            // "postId": post.id,
        }
    });
}

Parse.Cloud.define("confirmFriendRequest", function(request, response) {
    var approvingUser = request.user;
    var requestingUserId = request.params.reqUserId;
    approvingUser.fetch({
        success: function(user) {
            // user is user approving the friends request
            Parse.Cloud.useMasterKey();
            query = new Parse.Query(Parse.User);
            query.get(requestingUserId, {
                success: function (object) {
                    // object is user requesting the friends request
                    var friendsArray = object.get("friendsArray");
                    var friendsPhones = object.get("friendsPhones");
                    if (!friendsArray.contains(user) && !friendsPhones.contains(user.phoneNumber)) {
                        friendsArray.push(user);
                        friendsPhones.push(user.phoneNumber);
                    } else {
                        return;
                    }
                    
                    object.save().then(
                        function (res) {
                            response.success("added " + user + " to friendsArray of " + object);
                            console.log(response);
                        }, function ( error) {
                             response.error(error);
                        });
                }, error: function (object, error) {
                    response.error(error);
                
                }    
            });
        }, 
        error: function(object, error) {
            response.error(error);
        }
    })
});





Parse.Cloud.define("sendFriendRequest", function(request, response) {
    var requestingUserId = request.user;
    var  targetUser = request.params.targetUserId;
    requestingUserId.fetch({
        success: function(user) {
            // user is user approving the friends request
            Parse.Cloud.useMasterKey();
            query = new Parse.Query(Parse.User);
            query.get(targetUser, {
                success: function (object) {
                    // object is user requesting the friends request
                    var friendRequestsArray = object.get("friendRequestsArray");
                    if (!friendRequestsArray.contains(user)) {
                        friendRequestsArray.push(user);    
                    } else {
                        return;
                    }
                    
                    object.save().then(
                        function (res) {
                            response.success("this guy " + user + " sent a friends req to this guy " + object);
                            console.log(response);
                        }, function ( error) {
                             response.error(error);
                        });
                }, error: function (object, error) {
                    response.error(error);
                
                }    
            });
        }, 
        error: function(object, error) {
            response.error(error);
        }
    })
});


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