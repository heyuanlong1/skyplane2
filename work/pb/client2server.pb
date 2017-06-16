
—B
client2server.protoclientToServerMsgcommonMessage.protologMessage.proto"Ü
loginRequest
deviceId (	
thirdAccountType (
thirdAccount (	
thirdPasswd (	
pfType (
version (	"a
loginResponse
	errorCode (

ip (	
port (
authCode (	
	accountId ("^
gameServerLoginRequest
	accountId (
authCode (	
pfType (
version (	",
gameServerLoginResponse
	errorCode ("!
pingRequest

clientTime ("5
pingResponse
	errorCode (

clientTime ("Œ
roleSynchronizeRequest
	mobileKey (	
version (	
pfType (
gold (
silver (
nickname (	
	headImage (
lastStrengthTime (
items (2.BagItem
	usedItems (2.BagItem!
goldSync (2.ClientGoldSync
level (2.MyLevelStorage
pushProvider (	
pushClientId (	"Î
roleSynchronizeResponse
	errorCode (
gold (
silver (
nickname (	
	headImage (
lastStrengthTime (
maxStrength (
items (2.BagItem
level (2.MyLevelStorage

usedCdkeys ("◊
synchronizeRequest
gold (
silver (
nickname (	
	headImage (
items (2.BagItem
	usedItems (2.BagItem!
goldSync (2.ClientGoldSync
clientTotalStar (
clientMaxPassedLevelId ()
changedWinLevel (2.ChangedWinLevel+
changedFailLevel (2.ChangedFailLevel
totalFailNum ("ì
synchronizeResponse
	errorCode (
gold (
silver (
nickname (	
	headImage (
maxStrength (

syncResult
 (
items (2.BagItem

usedCdkeys ( 

basedLevel (2.LevelDetail
totalFailNum (
lastStarAwardNum ("W
synchronizeLevelRequest&
clientBasedLevel (2.LevelDetail
totalFailNum ("
synchronizeLevelResponse
	errorCode ( 

basedLevel (2.LevelDetail
totalFailNum (
lastStarAwardNum ("‘
logSynchronize
	mobileKey (	
version (	
pfType (6
logGamePauses (2.clientToServerMsg.LogGamePause8
logGameResumes (2 .clientToServerMsg.LogGameResume7
logEnterLevel (2 .clientToServerMsg.LogEnterLevel5
logExitLevel (2.clientToServerMsg.LogExitLevel,
logItems (2.clientToServerMsg.logItem"&
logSynchronizeRet
	errorCode ("N
sendNewPlayerEventRequest1
events (2!.clientToServerMsg.NewPlayerEvent"/
sendNewPlayerEventResponse
	errorCode ("G
sendGameResumeRequest.
data (2 .clientToServerMsg.LogGameResume"+
sendGameResumeResponse
	errorCode ("N
syncNewPlayerEventRequest1
events (2!.clientToServerMsg.NewPlayerEvent"/
syncNewPlayerEventResponse
	errorCode (":
syncBaseInfoRequest
	headImage (
nickname (	")
syncBaseInfoResponse
	errorCode ("9
getStoreInfoRequest
placeholder (
iccid (	"ç
getStoreInfoResponse
	errorCode (
item (2
.storeGood#

miguCharge (2.ChargeTypeInfo#

oppoCharge (2.ChargeTypeInfo"é
buyItemRequest
pfID (
pkID (	
payID (
opID (
appID (	
itemId (
buyType (
	storeType (
payCurrency	 (	
buyCount
 (
	realPrice (

totalPrice (
levelId (!
goldSync (2.ClientGoldSync"S
buyItemResponse
	errorCode (
orderId (	

awardItems (2.BagItem"U
deliverItemNotify
	errorCode (
orderId (	

awardItems (2.BagItem"#
starAwardRequest
starNum ("D
starAwardResponse
	errorCode (

awardItems (2.BagItem"0
getSignInAwardInfoRequest
placeholder ("z
getSignInAwardInfoResponse
	errorCode (
	showItems (2	.ShowItem
receiveIndex (
todayReceived (",
getSignInAwardRequest
placeholder ("X
getSignInAwardResponse
	errorCode (
index (

awardItems (2.BagItem"-
getSigninInfo2Requeset
placeholder ("ï
getSigninInfo2Response
	errorCode (
	showItems (2	.ShowItem
receiveStatus (

todayIndex (
fullShowItem (2	.ShowItem"'
getSigninAward2Request
index ("h
getSigninAward2Response
	errorCode (

awardItems (2.BagItem

fullAwards (2.BagItem"!
getUpdatePrize
version (	"U
getUpdatePrizeRet
	errorCode (
version (	

awardItems (2.BagItem"-
recommendFriendRequest
placeholder ("J
recommendFriendResponse
	errorCode (
players (2.PlayerInfo"+
getFriendInfoRequest
placeholder ("E
getFriendInfoResponse
	errorCode (
info (2.FriendInfo",
getFriendLevelRankRequest
levelId ("ò
getFriendLevelRankResponse
	errorCode (

accountIds (
	headImage (
nickname (	
score (
myRank (
myScore ("&
addFriendRequest

accountIds ("A
addFriendResponse
	errorCode (
info (2.FriendInfo")
removeFriendRequest

accountIds (")
removeFriendResponse
	errorCode ("%
getMailRequest
placeholder ("=
getMailResponse
	errorCode (
mail (2	.MailInfo"2
procMailRequest
mailIds (
result ("T
procMailResponse
	errorCode (
mailIds (

awardItems (2.BagItem"7
 getFriendListForStrengthRequesst
placeholder ("I
 getFriendListForStrengthResponse
	errorCode (

accountIds ("1
askFriendForStrengthRequest

accountIds ("E
askFriendForStrengthResponse
	errorCode (

accountIds ("/
enterInfiniteModeRequest
placeholder (".
enterInfiniteModeResponse
	errorCode ("_
exitInfiniteModeRequest

gameResult (
score (
level (

remainStep ("-
exitInfiniteModeResponse
	errorCode ("*
InfiniteModeRequest
placeholder ("ﬁ
InfiniteModeResponse
	errorCode (
levelIds (
scores (
rewardLevelIds (
rewardLevelLimits (
limit (

accountIds (
	additions (
dayAwardMax	 (
dayAwardGot
 ("/
InfiniteModeInviteRequest

accountIds ("C
InfiniteModeInviteResponse
	errorCode (

accountIds ("6
InfiniteModeWinRequest
level (
score (",
InfiniteModeWinResponse
	errorCode ("/
InfiniteModeAwardRequest
placeholder ("L
InfiniteModeAwardResponse
	errorCode (

awardItems (2.BagItem".
InfiniteModeRankRequest
placeholder ("ñ
InfiniteModeRankResponse
	errorCode (

accountIds (
	headImage (
nickname (	
score (
myRank (
myScore ("7
 getFriendInfiniteModeRankRequest
placeholder ("ü
!getFriendInfiniteModeRankResponse
	errorCode (

accountIds (
	headImage (
nickname (	
score (
myRank (
myScore ("/
getNewbieGiftInfoRequest
placeholder ("M
getNewbieGiftInfoResponse
	errorCode (
info (2.NewbieGiftInfo"%
getNewbieGiftRequest
index ("b
getNewbieGiftResponse
	errorCode (
items (2.BagItem
info (2.NewbieGiftInfo"&
getPushGiftRequest
giftType ("ô
getPushGiftResponse
	errorCode (
hasGift (

remainTime ( 
pushGiftInfo (2
.storeGood
isFirstRequest (
giftType ("-
getPushGiftSellRequest
placeholder ("ä
getPushGiftSellResponse
	errorCode (

accountIds (
	headImage (
nickname (	
money (
buyPlayerNum (")
getTaskListRequest
placeholder ("Z
getTaskListResponse
	errorCode (
exp (2	.taskInfo
daily (2	.taskInfo"8
getTaskRewardRequest
taskId (
taskType ("a
getTaskRewardResponse
	errorCode (
info (2	.taskInfo

awardItems (2.BagItem"(
getActivityRequest

activityId ("g
getActivityResponse
	errorCode (

remainTime ()
christmasInfo (2.ChristmasActivity"a
getActivityRewardRequest

activityId (1
christmasReward (2.ChristmasActivityReward"L
getActivityRewardResponse
	errorCode (

awardItems (2.BagItem"/
day2ActiviityInfoRequest
placeholder ("V
day2ActiviityInfoResponse
	errorCode (

remainTime (

canReceive ("/
day2ActivityAwardRequest
placeholder ("L
day2ActivityAwardResponse
	errorCode (

awardItems (2.BagItem"1
receiveStrengthInfoRequest
placeholder ("Y
receiveStrengthInfoResponse
	errorCode (
isValidTime (

isReceived ("-
receiveStrengthRequest
placeholder (",
receiveStrengthResponse
	errorCode (