
/*** Twilio ***/
// Require and initialize the Twilio module with your credentials

var ACCOUNT_SID = "AC86b279230f26f7ca6293af12e5713e9d";
var AUTH_TOKEN = "17d74223b2e0e2dff89e7b35b52eb9ac";

Array.prototype.arrayContains = function(obj) {
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


var getContactNameFromPhoneNumber = function(userId, phoneNumber) {
    console.log("starting getContactNameFromPhoneNumber.....");
    Parse.Cloud.useMasterKey();
    query = new Parse.Query(Parse.User);
        query.get(userId, {
            success: function (object) {
                // object is user requesting the friends request
                // var friendsArray = object.get("friendsArray");
                // var friendsPhones = object.get("friendsPhones");
                // if (!friendsArray.arrayContains(user) && !friendsPhones.arrayContains(user.phoneNumber)) {
                //     friendsArray.push(user);
                //     friendsPhones.push(user.phoneNumber);
                // } else {
                //     return;
                // }
                
                // object.save().then(
                //     function (res) {
                response.success("getContactNameFromPhoneNumber " + object);
                        // console.log(response);
                    // }, function ( error) {
                         // response.error(error);
                    // });
            }, error: function (object, error) {
                response.error(error);
            
            }    
        });

}

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

Parse.Cloud.beforeSave("Message", function(request, response) {
    console.log("Message before save request");
    // console.log(request.params);
    var batchId = request.object.get("batchId");
    console.log("This is the batchId " +batchId);
    if (!batchId) {
        response.error("No batchId");
    } else {
        // var username = request.user.get("username");
        query = new Parse.Query("Interaction");
        var batchIdArray = new Array();
        batchIdArray.push(batchId);
        query.equalTo("batchIds", batchId);
        query.find({
            success: function(results) {
                console.log("Found " + results.length + " interactions to update");
                var interactionsToSave = new Array();
                for (var i = 0; i< results.length; i++) {
                    var interaction = results[i];
                    interaction.set("updated", true);
                    interactionsToSave.push(interaction);
                }
            // results is an array of Parse.Object.
                // console.log("found " + results.count + " interactions to update");
                Parse.Object.saveAll(interactionsToSave).then(function(res) {
                    console.log("succesfuly updated interactions");
                    response.success();       
                });
                
            },

            error: function(error) {
                response.error(error);
            // error is an instance of Parse.Error.
            }
        });
    }
});

Parse.Cloud.define("sendSprayPushNotifications", function(request, response) {
    console.log("sendSprayPushNotifications");
    var subscribersArray = request.params.recipients;
    
    if (subscribersArray.length < 1) {
        response.error("No recipients");
    } else {
        var username = request.user.get("username");
        var senderPhoneNumber= request.user.get("phoneNumber");
        // getContactNameFromPhoneNumber(, senderPhoneNumber);        
        console.log("trying to get name for phonenumber " +senderPhoneNumber + " and this id" + subscribersArray[0]);
        Parse.Cloud.useMasterKey();

        for (var i = 0; i < subscribersArray.length; i++) {
            var recipient = subscribersArray[i];
            // var recipientUser = recipient.fetch();
            var id = recipient;
            if (id === request.user.id) continue;
            var channel = "tap" + id;

           var targetUser = new Parse.User({id:id});
           console.log("target user");
           targetUser.fetch().then( function ( fetched) {
                console.log("FETCHEEEDDDDD");
           });
            sendDefaultPush(channel, "From " + username, "newtap");
        }
        response.success();   
    }
});


var sendDefaultPush = function(channel, alert, type) {
    console.log("sending default push to channel " + channel + " with message: " + alert + " and type: "+ type);
    Parse.Push.send({
        channels: [channel],
        data: {
            "alert": alert,
            "sound": "default",
            "badge": "Increment",
            "type":type,//,
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
                    if (!friendsArray.arrayContains(user) && !friendsPhones.arrayContains(user.phoneNumber)) {
                        friendsArray.push(user);
                        friendsPhones.push(user.phoneNumber);
                    } else {
                        return;
                    }
                    
                    object.save().then(
                        function (res) {
                            var contactsDict = object.get("contactsDict");
                            var userPhoneNumber = user.get("phoneNumber");
                            var friendRequsterNameInContacts = contactsDict[userPhoneNumber];
                            sendDefaultPush("tap" + object.id, friendRequsterNameInContacts + " accepted your friend request!", "approvedFriendRequest");
                            response.success();
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


var getNameByPhoneNumber = function (currentUser, targetUserId) {
    console.log("getNameByPhoneNumber");
    Parse.Cloud.useMasterKey();
    // var currentUser = new Parse.User(currentUserId);
    currentUser.fetch({
        success: function(user) {
            Parse.Cloud.useMasterKey();
            query = new Parse.Query(Parse.User);
            query.get(targetUserId, {
                success: function (object) {
                    var contactsDict = object.get("contactsDict");
                    var userPhoneNumber = user.get("phoneNumber");
                    console.log("userPhoneNumber "+ userPhoneNumber);
                    var currentUserNameInContacts = contactsDict[userPhoneNumber];
                    console.log("current name " + currentUserNameInContacts);
                    response.success();
                    return currentUserNameInContacts;
                }, error : function ( error) {
                     response.error(error);
                }
            });
        }, error: function (object, error) {
            response.error(error);
        }    
    });     
}


// Parse.Cloud.define("sendFriendRequest", function(request, response) {
//     var requestingUserId = request.user;
//     var  targetUser = request.params.targetUserId;
    
//     requestingUserId.fetch({
//         success: function(user) {
//             // user is user approving the friends request
//             Parse.Cloud.useMasterKey();
//             query = new Parse.Query(Parse.User);
//             query.get(targetUser, {
//                 success: function (object) {
//                     // object is user requesting the friends request
                    
//                     var friendRequestsArray = object.get("friendRequestsArray");

//                     if (!friendRequestsArray.arrayContains(user)) {
//                         friendRequestsArray.push(user);    
//                     } else {
//                         return;
//                     }
                    
//                     object.save().then(
//                         function (res) {
//                             var contactsDict = object.get("contactsDict");
//                             var userPhoneNumber = user.get("phoneNumber");
//                             var friendRequsterNameInContacts = contactsDict[userPhoneNumber];
//                             sendDefaultPush("tap" + object.id, friendRequsterNameInContacts + " added you as a friend", "sendFriendRequest");
//                             response.success();
//                             console.log(response);
//                         }, function ( error) {
//                              response.error(error);
//                         });
//                 }, error: function (object, error) {
//                     response.error(error);
                
//                 }    
//             });
//         }, 
//         error: function(object, error) {
//             response.error(error);
//         }
//     })
// });


Parse.Cloud.beforeSave("FriendRequest", function(request, response) {
    console.log("Before save FriendRequest");
    var requestingUser = request.user;
    var targetUser = request.object.get("targetUser").id;
    var requestingUserPhoneNumber = request.object.get("requestingUserPhoneNumber");
    var requestingUserUsername = request.object.get("requestingUserUsername");
    
    console.log("target user");
    console.log(targetUser);
    console.log("reqesting phone number " + requestingUserPhoneNumber);
    console.log("reqesting username " + requestingUserUsername);
    
    requestingUser.fetch({
        success: function ( user) {
            console.log("Fetched requesting user");

            query = new Parse.Query(Parse.User);
            query.get(targetUser, {
                success: function (object) {
                    console.log("got target user");
                    Parse.Cloud.useMasterKey();
                    var contactsDict = object.get("contactsDict");
                    var friendRequsterNameInContacts = contactsDict[requestingUserPhoneNumber];
                    if (!friendRequsterNameInContacts) {
                        friendRequsterNameInContacts = requestingUserUsername;
                    }
                    sendDefaultPush("tap" + object.id, friendRequsterNameInContacts + " sent you a friend request", "sendFriendRequest");
                 response.success();
                },
                error: function ( error) {
                    // console.log();
                    response.error("couldn't get target user");
                    
                }
            });
               
        }, error : function (error ) {
            console.log(error);
            response.error();
        }
    })


    // requestingUser.fetch({
    //     success: function(user) {
    //         Parse.Cloud.useMasterKey();
    //         query = new Parse.Query(Parse.User);
    //         query.get(targetUser, {
    //             success: function (object) {
    //                 // object is user requesting the friends request
    //                 var friendRequestsArray = object.get("friendRequestsArray");

    //                 if (!friendRequestsArray.arrayContains(user)) {
    //                     friendRequestsArray.push(user);    
    //                 } else {
    //                     return;
    //                 }
    //                 object.save().then(
    //                     function (res) {
    //                         var contactsDict = object.get("contactsDict");
    //                         var userPhoneNumber = requestingUserUsername
    //                         var friendRequsterNameInContacts = contactsDict[userPhoneNumber];
    //                         if (!friendRequsterNameInContacts) friendRequsterNameInContacts = requestingUserUsername;

    //                         sendDefaultPush("tap" + object.id, friendRequsterNameInContacts + " added you as a friend", "sendFriendRequest");
                            
    //                         response.success();
    //                         console.log(response);
    //                     }, function ( error) {
    //                          response.error(error);
    //                     });
    //             }, error: function (object, error) {
    //                 response.error(error);
                
    //             }    
    //         });
    //     }, 
    //     error: function(object, error) {
    //         response.error(error);
    //     }
    // })
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