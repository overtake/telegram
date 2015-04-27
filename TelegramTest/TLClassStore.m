//
//  TLClassStore.m
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/26/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TLClassStore.h"
#import "TLObject.h"
#import "TLApi.h"


@interface TLClassStore()
@property (nonatomic, strong) NSMutableDictionary *classes;
@property (nonatomic, strong) NSMutableDictionary *constuctors;
@end

@implementation TLClassStore


- (id)init {
    self = [super init];
    if(self) {
        self.classes = [[NSMutableDictionary alloc] init];
        self.constuctors = [[NSMutableDictionary alloc] init];
        
        [self.classes setObject:[TL_boolFalse class] forKey:[NSNumber numberWithInt:-1132882121]];
        [self.classes setObject:[TL_boolTrue class] forKey:[NSNumber numberWithInt:-1720552011]];
        [self.classes setObject:[TL_inputPeerEmpty class] forKey:[NSNumber numberWithInt:2134579434]];
        [self.classes setObject:[TL_inputPeerSelf class] forKey:[NSNumber numberWithInt:2107670217]];
        [self.classes setObject:[TL_inputPeerContact class] forKey:[NSNumber numberWithInt:270785512]];
        [self.classes setObject:[TL_inputPeerForeign class] forKey:[NSNumber numberWithInt:-1690012891]];
        [self.classes setObject:[TL_inputPeerChat class] forKey:[NSNumber numberWithInt:396093539]];
        [self.classes setObject:[TL_inputUserEmpty class] forKey:[NSNumber numberWithInt:-1182234929]];
        [self.classes setObject:[TL_inputUserSelf class] forKey:[NSNumber numberWithInt:-138301121]];
        [self.classes setObject:[TL_inputUserContact class] forKey:[NSNumber numberWithInt:-2031530139]];
        [self.classes setObject:[TL_inputUserForeign class] forKey:[NSNumber numberWithInt:1700689151]];
        [self.classes setObject:[TL_inputPhoneContact class] forKey:[NSNumber numberWithInt:-208488460]];
        [self.classes setObject:[TL_inputFile class] forKey:[NSNumber numberWithInt:-181407105]];
        [self.classes setObject:[TL_inputMediaEmpty class] forKey:[NSNumber numberWithInt:-1771768449]];
        [self.classes setObject:[TL_inputMediaUploadedPhoto class] forKey:[NSNumber numberWithInt:-139464256]];
        [self.classes setObject:[TL_inputMediaPhoto class] forKey:[NSNumber numberWithInt:-373312269]];
        [self.classes setObject:[TL_inputMediaGeoPoint class] forKey:[NSNumber numberWithInt:-104578748]];
        [self.classes setObject:[TL_inputMediaContact class] forKey:[NSNumber numberWithInt:-1494984313]];
        [self.classes setObject:[TL_inputMediaUploadedVideo class] forKey:[NSNumber numberWithInt:-515910468]];
        [self.classes setObject:[TL_inputMediaUploadedThumbVideo class] forKey:[NSNumber numberWithInt:-1761896484]];
        [self.classes setObject:[TL_inputMediaVideo class] forKey:[NSNumber numberWithInt:-1821749571]];
        [self.classes setObject:[TL_inputChatPhotoEmpty class] forKey:[NSNumber numberWithInt:480546647]];
        [self.classes setObject:[TL_inputChatUploadedPhoto class] forKey:[NSNumber numberWithInt:-1809496270]];
        [self.classes setObject:[TL_inputChatPhoto class] forKey:[NSNumber numberWithInt:-1293828344]];
        [self.classes setObject:[TL_inputGeoPointEmpty class] forKey:[NSNumber numberWithInt:-457104426]];
        [self.classes setObject:[TL_inputGeoPoint class] forKey:[NSNumber numberWithInt:-206066487]];
        [self.classes setObject:[TL_inputPhotoEmpty class] forKey:[NSNumber numberWithInt:483901197]];
        [self.classes setObject:[TL_inputPhoto class] forKey:[NSNumber numberWithInt:-74070332]];
        [self.classes setObject:[TL_inputVideoEmpty class] forKey:[NSNumber numberWithInt:1426648181]];
        [self.classes setObject:[TL_inputVideo class] forKey:[NSNumber numberWithInt:-296249774]];
        [self.classes setObject:[TL_inputFileLocation class] forKey:[NSNumber numberWithInt:342061462]];
        [self.classes setObject:[TL_inputVideoFileLocation class] forKey:[NSNumber numberWithInt:1023632620]];
        [self.classes setObject:[TL_inputPhotoCropAuto class] forKey:[NSNumber numberWithInt:-1377390588]];
        [self.classes setObject:[TL_inputPhotoCrop class] forKey:[NSNumber numberWithInt:-644787419]];
        [self.classes setObject:[TL_inputAppEvent class] forKey:[NSNumber numberWithInt:1996904104]];
        [self.classes setObject:[TL_peerUser class] forKey:[NSNumber numberWithInt:-1649296275]];
        [self.classes setObject:[TL_peerChat class] forKey:[NSNumber numberWithInt:-1160714821]];
        [self.classes setObject:[TL_storage_fileUnknown class] forKey:[NSNumber numberWithInt:-1432995067]];
        [self.classes setObject:[TL_storage_fileJpeg class] forKey:[NSNumber numberWithInt:8322574]];
        [self.classes setObject:[TL_storage_fileGif class] forKey:[NSNumber numberWithInt:-891180321]];
        [self.classes setObject:[TL_storage_filePng class] forKey:[NSNumber numberWithInt:172975040]];
        [self.classes setObject:[TL_storage_filePdf class] forKey:[NSNumber numberWithInt:-1373745011]];
        [self.classes setObject:[TL_storage_fileMp3 class] forKey:[NSNumber numberWithInt:1384777335]];
        [self.classes setObject:[TL_storage_fileMov class] forKey:[NSNumber numberWithInt:1258941372]];
        [self.classes setObject:[TL_storage_filePartial class] forKey:[NSNumber numberWithInt:1086091090]];
        [self.classes setObject:[TL_storage_fileMp4 class] forKey:[NSNumber numberWithInt:-1278304028]];
        [self.classes setObject:[TL_storage_fileWebp class] forKey:[NSNumber numberWithInt:276907596]];
        [self.classes setObject:[TL_fileLocationUnavailable class] forKey:[NSNumber numberWithInt:2086234950]];
        [self.classes setObject:[TL_fileLocation class] forKey:[NSNumber numberWithInt:1406570614]];
        [self.classes setObject:[TL_userEmpty class] forKey:[NSNumber numberWithInt:537022650]];
        [self.classes setObject:[TL_userSelf class] forKey:[NSNumber numberWithInt:476112392]];
        [self.classes setObject:[TL_userContact class] forKey:[NSNumber numberWithInt:-894214632]];
        [self.classes setObject:[TL_userRequest class] forKey:[NSNumber numberWithInt:-640891665]];
        [self.classes setObject:[TL_userForeign class] forKey:[NSNumber numberWithInt:123533224]];
        [self.classes setObject:[TL_userDeleted class] forKey:[NSNumber numberWithInt:-704549510]];
        [self.classes setObject:[TL_userProfilePhotoEmpty class] forKey:[NSNumber numberWithInt:1326562017]];
        [self.classes setObject:[TL_userProfilePhoto class] forKey:[NSNumber numberWithInt:-715532088]];
        [self.classes setObject:[TL_userStatusEmpty class] forKey:[NSNumber numberWithInt:164646985]];
        [self.classes setObject:[TL_userStatusOnline class] forKey:[NSNumber numberWithInt:-306628279]];
        [self.classes setObject:[TL_userStatusOffline class] forKey:[NSNumber numberWithInt:9203775]];
        [self.classes setObject:[TL_chatEmpty class] forKey:[NSNumber numberWithInt:-1683826688]];
        [self.classes setObject:[TL_chat class] forKey:[NSNumber numberWithInt:1855757255]];
        [self.classes setObject:[TL_chatForbidden class] forKey:[NSNumber numberWithInt:-83047359]];
        [self.classes setObject:[TL_chatFull class] forKey:[NSNumber numberWithInt:-891418735]];
        [self.classes setObject:[TL_chatParticipant class] forKey:[NSNumber numberWithInt:-925415106]];
        [self.classes setObject:[TL_chatParticipantsForbidden class] forKey:[NSNumber numberWithInt:265468810]];
        [self.classes setObject:[TL_chatParticipants class] forKey:[NSNumber numberWithInt:2017571861]];
        [self.classes setObject:[TL_chatPhotoEmpty class] forKey:[NSNumber numberWithInt:935395612]];
        [self.classes setObject:[TL_chatPhoto class] forKey:[NSNumber numberWithInt:1632839530]];
        [self.classes setObject:[TL_messageEmpty class] forKey:[NSNumber numberWithInt:-2082087340]];
        [self.classes setObject:[TL_message class] forKey:[NSNumber numberWithInt:-1481959023]];
        [self.classes setObject:[TL_messageService class] forKey:[NSNumber numberWithInt:495384334]];
        [self.classes setObject:[TL_messageMediaEmpty class] forKey:[NSNumber numberWithInt:1038967584]];
        [self.classes setObject:[TL_messageMediaPhoto class] forKey:[NSNumber numberWithInt:1032643901]];
        [self.classes setObject:[TL_messageMediaVideo class] forKey:[NSNumber numberWithInt:1540298357]];
        [self.classes setObject:[TL_messageMediaGeo class] forKey:[NSNumber numberWithInt:1457575028]];
        [self.classes setObject:[TL_messageMediaContact class] forKey:[NSNumber numberWithInt:1585262393]];
        [self.classes setObject:[TL_messageMediaUnsupported class] forKey:[NSNumber numberWithInt:-1618676578]];
        [self.classes setObject:[TL_messageActionEmpty class] forKey:[NSNumber numberWithInt:-1230047312]];
        [self.classes setObject:[TL_messageActionChatCreate class] forKey:[NSNumber numberWithInt:-1503425638]];
        [self.classes setObject:[TL_messageActionChatEditTitle class] forKey:[NSNumber numberWithInt:-1247687078]];
        [self.classes setObject:[TL_messageActionChatEditPhoto class] forKey:[NSNumber numberWithInt:2144015272]];
        [self.classes setObject:[TL_messageActionChatDeletePhoto class] forKey:[NSNumber numberWithInt:-1780220945]];
        [self.classes setObject:[TL_messageActionChatAddUser class] forKey:[NSNumber numberWithInt:1581055051]];
        [self.classes setObject:[TL_messageActionChatDeleteUser class] forKey:[NSNumber numberWithInt:-1297179892]];
        [self.classes setObject:[TL_dialog class] forKey:[NSNumber numberWithInt:-1042448310]];
        [self.classes setObject:[TL_photoEmpty class] forKey:[NSNumber numberWithInt:590459437]];
        [self.classes setObject:[TL_photo class] forKey:[NSNumber numberWithInt:-1014792074]];
        [self.classes setObject:[TL_photoSizeEmpty class] forKey:[NSNumber numberWithInt:236446268]];
        [self.classes setObject:[TL_photoSize class] forKey:[NSNumber numberWithInt:2009052699]];
        [self.classes setObject:[TL_photoCachedSize class] forKey:[NSNumber numberWithInt:-374917894]];
        [self.classes setObject:[TL_videoEmpty class] forKey:[NSNumber numberWithInt:-1056548696]];
        [self.classes setObject:[TL_video class] forKey:[NSNumber numberWithInt:-291550643]];
        [self.classes setObject:[TL_geoPointEmpty class] forKey:[NSNumber numberWithInt:286776671]];
        [self.classes setObject:[TL_geoPoint class] forKey:[NSNumber numberWithInt:541710092]];
        [self.classes setObject:[TL_auth_checkedPhone class] forKey:[NSNumber numberWithInt:-2128698738]];
        [self.classes setObject:[TL_auth_sentCode class] forKey:[NSNumber numberWithInt:-269659687]];
        [self.classes setObject:[TL_auth_authorization class] forKey:[NSNumber numberWithInt:-155815004]];
        [self.classes setObject:[TL_auth_exportedAuthorization class] forKey:[NSNumber numberWithInt:-543777747]];
        [self.classes setObject:[TL_inputNotifyPeer class] forKey:[NSNumber numberWithInt:-1195615476]];
        [self.classes setObject:[TL_inputNotifyUsers class] forKey:[NSNumber numberWithInt:423314455]];
        [self.classes setObject:[TL_inputNotifyChats class] forKey:[NSNumber numberWithInt:1251338318]];
        [self.classes setObject:[TL_inputNotifyAll class] forKey:[NSNumber numberWithInt:-1540769658]];
        [self.classes setObject:[TL_inputPeerNotifyEventsEmpty class] forKey:[NSNumber numberWithInt:-265263912]];
        [self.classes setObject:[TL_inputPeerNotifyEventsAll class] forKey:[NSNumber numberWithInt:-395694988]];
        [self.classes setObject:[TL_inputPeerNotifySettings class] forKey:[NSNumber numberWithInt:1185074840]];
        [self.classes setObject:[TL_peerNotifyEventsEmpty class] forKey:[NSNumber numberWithInt:-1378534221]];
        [self.classes setObject:[TL_peerNotifyEventsAll class] forKey:[NSNumber numberWithInt:1830677896]];
        [self.classes setObject:[TL_peerNotifySettingsEmpty class] forKey:[NSNumber numberWithInt:1889961234]];
        [self.classes setObject:[TL_peerNotifySettings class] forKey:[NSNumber numberWithInt:-1923214866]];
        [self.classes setObject:[TL_wallPaper class] forKey:[NSNumber numberWithInt:-860866985]];
        [self.classes setObject:[TL_userFull class] forKey:[NSNumber numberWithInt:1997575642]];
        [self.classes setObject:[TL_contact class] forKey:[NSNumber numberWithInt:-116274796]];
        [self.classes setObject:[TL_importedContact class] forKey:[NSNumber numberWithInt:-805141448]];
        [self.classes setObject:[TL_contactBlocked class] forKey:[NSNumber numberWithInt:1444661369]];
        [self.classes setObject:[TL_contactSuggested class] forKey:[NSNumber numberWithInt:1038193057]];
        [self.classes setObject:[TL_contactStatus class] forKey:[NSNumber numberWithInt:-748155807]];
        [self.classes setObject:[TL_chatLocated class] forKey:[NSNumber numberWithInt:909233996]];
        [self.classes setObject:[TL_contacts_link class] forKey:[NSNumber numberWithInt:986597452]];
        [self.classes setObject:[TL_contacts_contactsNotModified class] forKey:[NSNumber numberWithInt:-1219778094]];
        [self.classes setObject:[TL_contacts_contacts class] forKey:[NSNumber numberWithInt:1871416498]];
        [self.classes setObject:[TL_contacts_importedContacts class] forKey:[NSNumber numberWithInt:-1387117803]];
        [self.classes setObject:[TL_contacts_blocked class] forKey:[NSNumber numberWithInt:471043349]];
        [self.classes setObject:[TL_contacts_blockedSlice class] forKey:[NSNumber numberWithInt:-1878523231]];
        [self.classes setObject:[TL_contacts_suggested class] forKey:[NSNumber numberWithInt:1447681221]];
        [self.classes setObject:[TL_messages_dialogs class] forKey:[NSNumber numberWithInt:364538944]];
        [self.classes setObject:[TL_messages_dialogsSlice class] forKey:[NSNumber numberWithInt:1910543603]];
        [self.classes setObject:[TL_messages_messages class] forKey:[NSNumber numberWithInt:-1938715001]];
        [self.classes setObject:[TL_messages_messagesSlice class] forKey:[NSNumber numberWithInt:189033187]];
        [self.classes setObject:[TL_messages_messageEmpty class] forKey:[NSNumber numberWithInt:1062078024]];
        [self.classes setObject:[TL_messages_sentMessage class] forKey:[NSNumber numberWithInt:1279084531]];
        [self.classes setObject:[TL_messages_chats class] forKey:[NSNumber numberWithInt:1694474197]];
        [self.classes setObject:[TL_messages_chatFull class] forKey:[NSNumber numberWithInt:-438840932]];
        [self.classes setObject:[TL_messages_affectedHistory class] forKey:[NSNumber numberWithInt:-1269012015]];
        [self.classes setObject:[TL_inputMessagesFilterEmpty class] forKey:[NSNumber numberWithInt:1474492012]];
        [self.classes setObject:[TL_inputMessagesFilterPhotos class] forKey:[NSNumber numberWithInt:-1777752804]];
        [self.classes setObject:[TL_inputMessagesFilterVideo class] forKey:[NSNumber numberWithInt:-1614803355]];
        [self.classes setObject:[TL_inputMessagesFilterPhotoVideo class] forKey:[NSNumber numberWithInt:1458172132]];
        [self.classes setObject:[TL_inputMessagesFilterPhotoVideoDocuments class] forKey:[NSNumber numberWithInt:-648121413]];
        [self.classes setObject:[TL_inputMessagesFilterDocument class] forKey:[NSNumber numberWithInt:-1629621880]];
        [self.classes setObject:[TL_inputMessagesFilterAudio class] forKey:[NSNumber numberWithInt:-808946398]];
        [self.classes setObject:[TL_updateNewMessage class] forKey:[NSNumber numberWithInt:522914557]];
        [self.classes setObject:[TL_updateMessageID class] forKey:[NSNumber numberWithInt:1318109142]];
        [self.classes setObject:[TL_updateDeleteMessages class] forKey:[NSNumber numberWithInt:-1576161051]];
        [self.classes setObject:[TL_updateUserTyping class] forKey:[NSNumber numberWithInt:1548249383]];
        [self.classes setObject:[TL_updateChatUserTyping class] forKey:[NSNumber numberWithInt:-1704596961]];
        [self.classes setObject:[TL_updateChatParticipants class] forKey:[NSNumber numberWithInt:125178264]];
        [self.classes setObject:[TL_updateUserStatus class] forKey:[NSNumber numberWithInt:469489699]];
        [self.classes setObject:[TL_updateUserName class] forKey:[NSNumber numberWithInt:-1489818765]];
        [self.classes setObject:[TL_updateUserPhoto class] forKey:[NSNumber numberWithInt:-1791935732]];
        [self.classes setObject:[TL_updateContactRegistered class] forKey:[NSNumber numberWithInt:628472761]];
        [self.classes setObject:[TL_updateContactLink class] forKey:[NSNumber numberWithInt:-1657903163]];
        [self.classes setObject:[TL_updateNewAuthorization class] forKey:[NSNumber numberWithInt:-1895411046]];
        [self.classes setObject:[TL_updates_state class] forKey:[NSNumber numberWithInt:-1519637954]];
        [self.classes setObject:[TL_updates_differenceEmpty class] forKey:[NSNumber numberWithInt:1567990072]];
        [self.classes setObject:[TL_updates_difference class] forKey:[NSNumber numberWithInt:16030880]];
        [self.classes setObject:[TL_updates_differenceSlice class] forKey:[NSNumber numberWithInt:-1459938943]];
        [self.classes setObject:[TL_updatesTooLong class] forKey:[NSNumber numberWithInt:-484987010]];
        [self.classes setObject:[TL_updateShortMessage class] forKey:[NSNumber numberWithInt:-312729305]];
        [self.classes setObject:[TL_updateShortChatMessage class] forKey:[NSNumber numberWithInt:1378061116]];
        [self.classes setObject:[TL_updateShort class] forKey:[NSNumber numberWithInt:2027216577]];
        [self.classes setObject:[TL_updatesCombined class] forKey:[NSNumber numberWithInt:1918567619]];
        [self.classes setObject:[TL_updates class] forKey:[NSNumber numberWithInt:1957577280]];
        [self.classes setObject:[TL_photos_photos class] forKey:[NSNumber numberWithInt:-1916114267]];
        [self.classes setObject:[TL_photos_photosSlice class] forKey:[NSNumber numberWithInt:352657236]];
        [self.classes setObject:[TL_photos_photo class] forKey:[NSNumber numberWithInt:539045032]];
        [self.classes setObject:[TL_upload_file class] forKey:[NSNumber numberWithInt:157948117]];
        [self.classes setObject:[TL_dcOption class] forKey:[NSNumber numberWithInt:784507964]];
        [self.classes setObject:[TL_config class] forKey:[NSNumber numberWithInt:1311946900]];
        [self.classes setObject:[TL_nearestDc class] forKey:[NSNumber numberWithInt:-1910892683]];
        [self.classes setObject:[TL_help_appUpdate class] forKey:[NSNumber numberWithInt:-1987579119]];
        [self.classes setObject:[TL_help_noAppUpdate class] forKey:[NSNumber numberWithInt:-1000708810]];
        [self.classes setObject:[TL_help_inviteText class] forKey:[NSNumber numberWithInt:415997816]];
        [self.classes setObject:[TL_messages_sentMessageLink class] forKey:[NSNumber numberWithInt:899786339]];
        [self.classes setObject:[TL_inputGeoChat class] forKey:[NSNumber numberWithInt:1960072954]];
        [self.classes setObject:[TL_inputNotifyGeoChatPeer class] forKey:[NSNumber numberWithInt:1301143240]];
        [self.classes setObject:[TL_geoChat class] forKey:[NSNumber numberWithInt:1978329690]];
        [self.classes setObject:[TL_geoChatMessageEmpty class] forKey:[NSNumber numberWithInt:1613830811]];
        [self.classes setObject:[TL_geoChatMessage class] forKey:[NSNumber numberWithInt:1158019297]];
        [self.classes setObject:[TL_geoChatMessageService class] forKey:[NSNumber numberWithInt:-749755826]];
        [self.classes setObject:[TL_geochats_statedMessage class] forKey:[NSNumber numberWithInt:397498251]];
        [self.classes setObject:[TL_geochats_located class] forKey:[NSNumber numberWithInt:1224651367]];
        [self.classes setObject:[TL_geochats_messages class] forKey:[NSNumber numberWithInt:-783127119]];
        [self.classes setObject:[TL_geochats_messagesSlice class] forKey:[NSNumber numberWithInt:-1135057944]];
        [self.classes setObject:[TL_messageActionGeoChatCreate class] forKey:[NSNumber numberWithInt:1862504124]];
        [self.classes setObject:[TL_messageActionGeoChatCheckin class] forKey:[NSNumber numberWithInt:209540062]];
        [self.classes setObject:[TL_updateNewGeoChatMessage class] forKey:[NSNumber numberWithInt:1516823543]];
        [self.classes setObject:[TL_wallPaperSolid class] forKey:[NSNumber numberWithInt:1662091044]];
        [self.classes setObject:[TL_updateNewEncryptedMessage class] forKey:[NSNumber numberWithInt:314359194]];
        [self.classes setObject:[TL_updateEncryptedChatTyping class] forKey:[NSNumber numberWithInt:386986326]];
        [self.classes setObject:[TL_updateEncryption class] forKey:[NSNumber numberWithInt:-1264392051]];
        [self.classes setObject:[TL_updateEncryptedMessagesRead class] forKey:[NSNumber numberWithInt:956179895]];
        [self.classes setObject:[TL_encryptedChatEmpty class] forKey:[NSNumber numberWithInt:-1417756512]];
        [self.classes setObject:[TL_encryptedChatWaiting class] forKey:[NSNumber numberWithInt:1006044124]];
        [self.classes setObject:[TL_encryptedChatRequested class] forKey:[NSNumber numberWithInt:-931638658]];
        [self.classes setObject:[TL_encryptedChat class] forKey:[NSNumber numberWithInt:-94974410]];
        [self.classes setObject:[TL_encryptedChatDiscarded class] forKey:[NSNumber numberWithInt:332848423]];
        [self.classes setObject:[TL_inputEncryptedChat class] forKey:[NSNumber numberWithInt:-247351839]];
        [self.classes setObject:[TL_encryptedFileEmpty class] forKey:[NSNumber numberWithInt:-1038136962]];
        [self.classes setObject:[TL_encryptedFile class] forKey:[NSNumber numberWithInt:1248893260]];
        [self.classes setObject:[TL_inputEncryptedFileEmpty class] forKey:[NSNumber numberWithInt:406307684]];
        [self.classes setObject:[TL_inputEncryptedFileUploaded class] forKey:[NSNumber numberWithInt:1690108678]];
        [self.classes setObject:[TL_inputEncryptedFile class] forKey:[NSNumber numberWithInt:1511503333]];
        [self.classes setObject:[TL_inputEncryptedFileLocation class] forKey:[NSNumber numberWithInt:-182231723]];
        [self.classes setObject:[TL_encryptedMessage class] forKey:[NSNumber numberWithInt:-317144808]];
        [self.classes setObject:[TL_encryptedMessageService class] forKey:[NSNumber numberWithInt:594758406]];
        [self.classes setObject:[TL_messages_dhConfigNotModified class] forKey:[NSNumber numberWithInt:-1058912715]];
        [self.classes setObject:[TL_messages_dhConfig class] forKey:[NSNumber numberWithInt:740433629]];
        [self.classes setObject:[TL_messages_sentEncryptedMessage class] forKey:[NSNumber numberWithInt:1443858741]];
        [self.classes setObject:[TL_messages_sentEncryptedFile class] forKey:[NSNumber numberWithInt:-1802240206]];
        [self.classes setObject:[TL_inputFileBig class] forKey:[NSNumber numberWithInt:-95482955]];
        [self.classes setObject:[TL_inputEncryptedFileBigUploaded class] forKey:[NSNumber numberWithInt:767652808]];
        [self.classes setObject:[TL_updateChatParticipantAdd class] forKey:[NSNumber numberWithInt:974056226]];
        [self.classes setObject:[TL_updateChatParticipantDelete class] forKey:[NSNumber numberWithInt:1851755554]];
        [self.classes setObject:[TL_updateDcOptions class] forKey:[NSNumber numberWithInt:-1906403213]];
        [self.classes setObject:[TL_inputMediaUploadedAudio class] forKey:[NSNumber numberWithInt:1313442987]];
        [self.classes setObject:[TL_inputMediaAudio class] forKey:[NSNumber numberWithInt:-1986820223]];
        [self.classes setObject:[TL_inputMediaUploadedDocument class] forKey:[NSNumber numberWithInt:-1610888]];
        [self.classes setObject:[TL_inputMediaUploadedThumbDocument class] forKey:[NSNumber numberWithInt:1095242886]];
        [self.classes setObject:[TL_inputMediaDocument class] forKey:[NSNumber numberWithInt:-779818943]];
        [self.classes setObject:[TL_messageMediaDocument class] forKey:[NSNumber numberWithInt:802824708]];
        [self.classes setObject:[TL_messageMediaAudio class] forKey:[NSNumber numberWithInt:-961117440]];
        [self.classes setObject:[TL_inputAudioEmpty class] forKey:[NSNumber numberWithInt:-648356732]];
        [self.classes setObject:[TL_inputAudio class] forKey:[NSNumber numberWithInt:2010398975]];
        [self.classes setObject:[TL_inputDocumentEmpty class] forKey:[NSNumber numberWithInt:1928391342]];
        [self.classes setObject:[TL_inputDocument class] forKey:[NSNumber numberWithInt:410618194]];
        [self.classes setObject:[TL_inputAudioFileLocation class] forKey:[NSNumber numberWithInt:1960591437]];
        [self.classes setObject:[TL_inputDocumentFileLocation class] forKey:[NSNumber numberWithInt:1313188841]];
        [self.classes setObject:[TL_audioEmpty class] forKey:[NSNumber numberWithInt:1483311320]];
        [self.classes setObject:[TL_audio class] forKey:[NSNumber numberWithInt:-945003370]];
        [self.classes setObject:[TL_documentEmpty class] forKey:[NSNumber numberWithInt:922273905]];
        [self.classes setObject:[TL_document class] forKey:[NSNumber numberWithInt:-106717361]];
        [self.classes setObject:[TL_help_support class] forKey:[NSNumber numberWithInt:398898678]];
        [self.classes setObject:[TL_notifyPeer class] forKey:[NSNumber numberWithInt:-1613493288]];
        [self.classes setObject:[TL_notifyUsers class] forKey:[NSNumber numberWithInt:-1261946036]];
        [self.classes setObject:[TL_notifyChats class] forKey:[NSNumber numberWithInt:-1073230141]];
        [self.classes setObject:[TL_notifyAll class] forKey:[NSNumber numberWithInt:1959820384]];
        [self.classes setObject:[TL_updateUserBlocked class] forKey:[NSNumber numberWithInt:-2131957734]];
        [self.classes setObject:[TL_updateNotifySettings class] forKey:[NSNumber numberWithInt:-1094555409]];
        [self.classes setObject:[TL_auth_sentAppCode class] forKey:[NSNumber numberWithInt:-484053553]];
        [self.classes setObject:[TL_sendMessageTypingAction class] forKey:[NSNumber numberWithInt:381645902]];
        [self.classes setObject:[TL_sendMessageCancelAction class] forKey:[NSNumber numberWithInt:-44119819]];
        [self.classes setObject:[TL_sendMessageRecordVideoAction class] forKey:[NSNumber numberWithInt:-1584933265]];
        [self.classes setObject:[TL_sendMessageUploadVideoAction class] forKey:[NSNumber numberWithInt:-378127636]];
        [self.classes setObject:[TL_sendMessageRecordAudioAction class] forKey:[NSNumber numberWithInt:-718310409]];
        [self.classes setObject:[TL_sendMessageUploadAudioAction class] forKey:[NSNumber numberWithInt:-212740181]];
        [self.classes setObject:[TL_sendMessageUploadPhotoAction class] forKey:[NSNumber numberWithInt:-774682074]];
        [self.classes setObject:[TL_sendMessageUploadDocumentAction class] forKey:[NSNumber numberWithInt:-1441998364]];
        [self.classes setObject:[TL_sendMessageGeoLocationAction class] forKey:[NSNumber numberWithInt:393186209]];
        [self.classes setObject:[TL_sendMessageChooseContactAction class] forKey:[NSNumber numberWithInt:1653390447]];
        [self.classes setObject:[TL_contactFound class] forKey:[NSNumber numberWithInt:-360210539]];
        [self.classes setObject:[TL_contacts_found class] forKey:[NSNumber numberWithInt:90570766]];
        [self.classes setObject:[TL_updateServiceNotification class] forKey:[NSNumber numberWithInt:942527460]];
        [self.classes setObject:[TL_userStatusRecently class] forKey:[NSNumber numberWithInt:-496024847]];
        [self.classes setObject:[TL_userStatusLastWeek class] forKey:[NSNumber numberWithInt:129960444]];
        [self.classes setObject:[TL_userStatusLastMonth class] forKey:[NSNumber numberWithInt:2011940674]];
        [self.classes setObject:[TL_updatePrivacy class] forKey:[NSNumber numberWithInt:-298113238]];
        [self.classes setObject:[TL_inputPrivacyKeyStatusTimestamp class] forKey:[NSNumber numberWithInt:1335282456]];
        [self.classes setObject:[TL_privacyKeyStatusTimestamp class] forKey:[NSNumber numberWithInt:-1137792208]];
        [self.classes setObject:[TL_inputPrivacyValueAllowContacts class] forKey:[NSNumber numberWithInt:218751099]];
        [self.classes setObject:[TL_inputPrivacyValueAllowAll class] forKey:[NSNumber numberWithInt:407582158]];
        [self.classes setObject:[TL_inputPrivacyValueAllowUsers class] forKey:[NSNumber numberWithInt:320652927]];
        [self.classes setObject:[TL_inputPrivacyValueDisallowContacts class] forKey:[NSNumber numberWithInt:195371015]];
        [self.classes setObject:[TL_inputPrivacyValueDisallowAll class] forKey:[NSNumber numberWithInt:-697604407]];
        [self.classes setObject:[TL_inputPrivacyValueDisallowUsers class] forKey:[NSNumber numberWithInt:-1877932953]];
        [self.classes setObject:[TL_privacyValueAllowContacts class] forKey:[NSNumber numberWithInt:-123988]];
        [self.classes setObject:[TL_privacyValueAllowAll class] forKey:[NSNumber numberWithInt:1698855810]];
        [self.classes setObject:[TL_privacyValueAllowUsers class] forKey:[NSNumber numberWithInt:1297858060]];
        [self.classes setObject:[TL_privacyValueDisallowContacts class] forKey:[NSNumber numberWithInt:-125240806]];
        [self.classes setObject:[TL_privacyValueDisallowAll class] forKey:[NSNumber numberWithInt:-1955338397]];
        [self.classes setObject:[TL_privacyValueDisallowUsers class] forKey:[NSNumber numberWithInt:209668535]];
        [self.classes setObject:[TL_account_privacyRules class] forKey:[NSNumber numberWithInt:1430961007]];
        [self.classes setObject:[TL_accountDaysTTL class] forKey:[NSNumber numberWithInt:-1194283041]];
        [self.classes setObject:[TL_account_sentChangePhoneCode class] forKey:[NSNumber numberWithInt:-1527411636]];
        [self.classes setObject:[TL_updateUserPhone class] forKey:[NSNumber numberWithInt:314130811]];
        [self.classes setObject:[TL_documentAttributeImageSize class] forKey:[NSNumber numberWithInt:1815593308]];
        [self.classes setObject:[TL_documentAttributeAnimated class] forKey:[NSNumber numberWithInt:297109817]];
        [self.classes setObject:[TL_documentAttributeSticker class] forKey:[NSNumber numberWithInt:-1723033470]];
        [self.classes setObject:[TL_documentAttributeVideo class] forKey:[NSNumber numberWithInt:1494273227]];
        [self.classes setObject:[TL_documentAttributeAudio class] forKey:[NSNumber numberWithInt:85215461]];
        [self.classes setObject:[TL_documentAttributeFilename class] forKey:[NSNumber numberWithInt:358154344]];
        [self.classes setObject:[TL_messages_stickersNotModified class] forKey:[NSNumber numberWithInt:-244016606]];
        [self.classes setObject:[TL_messages_stickers class] forKey:[NSNumber numberWithInt:-1970352846]];
        [self.classes setObject:[TL_stickerPack class] forKey:[NSNumber numberWithInt:313694676]];
        [self.classes setObject:[TL_messages_allStickersNotModified class] forKey:[NSNumber numberWithInt:-395967805]];
        [self.classes setObject:[TL_messages_allStickers class] forKey:[NSNumber numberWithInt:-588304126]];
        [self.classes setObject:[TL_disabledFeature class] forKey:[NSNumber numberWithInt:-1369215196]];
        [self.classes setObject:[TL_updateReadHistoryInbox class] forKey:[NSNumber numberWithInt:-1721631396]];
        [self.classes setObject:[TL_updateReadHistoryOutbox class] forKey:[NSNumber numberWithInt:791617983]];
        [self.classes setObject:[TL_messages_affectedMessages class] forKey:[NSNumber numberWithInt:-2066640507]];
        [self.classes setObject:[TL_contactLinkUnknown class] forKey:[NSNumber numberWithInt:1599050311]];
        [self.classes setObject:[TL_contactLinkNone class] forKey:[NSNumber numberWithInt:-17968211]];
        [self.classes setObject:[TL_contactLinkHasPhone class] forKey:[NSNumber numberWithInt:646922073]];
        [self.classes setObject:[TL_contactLinkContact class] forKey:[NSNumber numberWithInt:-721239344]];
        [self.classes setObject:[TL_updateWebPage class] forKey:[NSNumber numberWithInt:751004017]];
        [self.classes setObject:[TL_webPageEmpty class] forKey:[NSNumber numberWithInt:-350980120]];
        [self.classes setObject:[TL_webPagePending class] forKey:[NSNumber numberWithInt:-981018084]];
        [self.classes setObject:[TL_webPage class] forKey:[NSNumber numberWithInt:-1558273867]];
        [self.classes setObject:[TL_messageMediaWebPage class] forKey:[NSNumber numberWithInt:-1557277184]];
        [self.classes setObject:[TL_authorization class] forKey:[NSNumber numberWithInt:2079516406]];
        [self.classes setObject:[TL_account_authorizations class] forKey:[NSNumber numberWithInt:307276766]];
        [self.classes setObject:[TL_account_noPassword class] forKey:[NSNumber numberWithInt:-1764049896]];
        [self.classes setObject:[TL_account_password class] forKey:[NSNumber numberWithInt:2081952796]];
        [self.classes setObject:[TL_account_passwordSettings class] forKey:[NSNumber numberWithInt:-1212732749]];
        [self.classes setObject:[TL_account_passwordInputSettings class] forKey:[NSNumber numberWithInt:-1124314324]];
        [self.classes setObject:[TL_auth_passwordRecovery class] forKey:[NSNumber numberWithInt:326715557]];
        [self.classes setObject:[TL_inputMediaVenue class] forKey:[NSNumber numberWithInt:673687578]];
        [self.classes setObject:[TL_messageMediaVenue class] forKey:[NSNumber numberWithInt:2031269663]];
        [self.classes setObject:[TL_receivedNotifyMessage class] forKey:[NSNumber numberWithInt:-1551583367]];
        [self.classes setObject:[TL_chatInviteEmpty class] forKey:[NSNumber numberWithInt:1776236393]];
        [self.classes setObject:[TL_chatInviteExported class] forKey:[NSNumber numberWithInt:-64092740]];
        [self.classes setObject:[TL_chatInviteAlready class] forKey:[NSNumber numberWithInt:1516793212]];
        [self.classes setObject:[TL_chatInvite class] forKey:[NSNumber numberWithInt:-829325875]];
        [self.classes setObject:[TL_messageActionChatJoinedByLink class] forKey:[NSNumber numberWithInt:-123931160]];
        [self.classes setObject:[TL_updateReadMessagesContents class] forKey:[NSNumber numberWithInt:1757493555]];
        [self.classes setObject:[TL_proto_message class] forKey:[NSNumber numberWithInt:1538843921]];
        [self.classes setObject:[TL_msg_container class] forKey:[NSNumber numberWithInt:1945237724]];
        [self.classes setObject:[TL_req_pq class] forKey:[NSNumber numberWithInt:1615239032]];
        [self.classes setObject:[TL_server_DH_inner_data class] forKey:[NSNumber numberWithInt:-1249309254]];
        [self.classes setObject:[TL_p_q_inner_data class] forKey:[NSNumber numberWithInt:-2083955988]];
        [self.classes setObject:[TL_req_DH_params class] forKey:[NSNumber numberWithInt:-686627650]];
        [self.classes setObject:[TL_server_DH_params_fail class] forKey:[NSNumber numberWithInt:2043348061]];
        [self.classes setObject:[TL_server_DH_params_ok class] forKey:[NSNumber numberWithInt:-790100132]];
        [self.classes setObject:[TL_client_DH_inner_data class] forKey:[NSNumber numberWithInt:1715713620]];
        [self.classes setObject:[TL_set_client_DH_params class] forKey:[NSNumber numberWithInt:-184262881]];
        [self.classes setObject:[TL_dh_gen_ok class] forKey:[NSNumber numberWithInt:1003222836]];
        [self.classes setObject:[TL_dh_gen_retry class] forKey:[NSNumber numberWithInt:1188831161]];
        [self.classes setObject:[TL_dh_gen_fail class] forKey:[NSNumber numberWithInt:-1499615742]];
        [self.classes setObject:[TL_ping class] forKey:[NSNumber numberWithInt:2059302892]];
        [self.classes setObject:[TL_pong class] forKey:[NSNumber numberWithInt:880243653]];
        [self.classes setObject:[TL_bad_msg_notification class] forKey:[NSNumber numberWithInt:-1477445615]];
        [self.classes setObject:[TL_bad_server_salt class] forKey:[NSNumber numberWithInt:-307542917]];
        [self.classes setObject:[TL_new_session_created class] forKey:[NSNumber numberWithInt:-1631450872]];
        [self.classes setObject:[TL_rpc_result class] forKey:[NSNumber numberWithInt:-212046591]];
        [self.classes setObject:[TL_rpc_error class] forKey:[NSNumber numberWithInt:558156313]];
        [self.classes setObject:[TL_rsa_public_key class] forKey:[NSNumber numberWithInt:2048510838]];
        [self.classes setObject:[TL_resPQ class] forKey:[NSNumber numberWithInt:85337187]];
        [self.classes setObject:[TL_msgs_ack class] forKey:[NSNumber numberWithInt:1658238041]];
        [self.classes setObject:[TL_rpc_drop_answer class] forKey:[NSNumber numberWithInt:1491380032]];
        [self.classes setObject:[TL_rpc_answer_unknown class] forKey:[NSNumber numberWithInt:1579864942]];
        [self.classes setObject:[TL_rpc_answer_dropped_running class] forKey:[NSNumber numberWithInt:-847714938]];
        [self.classes setObject:[TL_rpc_answer_dropped class] forKey:[NSNumber numberWithInt:-1539647305]];
        [self.classes setObject:[TL_get_future_salts class] forKey:[NSNumber numberWithInt:-1188971260]];
        [self.classes setObject:[TL_future_salt class] forKey:[NSNumber numberWithInt:155834844]];
        [self.classes setObject:[TL_future_salts class] forKey:[NSNumber numberWithInt:-1370486635]];
        [self.classes setObject:[TL_destroy_session class] forKey:[NSNumber numberWithInt:-414113498]];
        [self.classes setObject:[TL_destroy_session_ok class] forKey:[NSNumber numberWithInt:-501201412]];
        [self.classes setObject:[TL_destroy_session_none class] forKey:[NSNumber numberWithInt:1658015945]];
        [self.classes setObject:[TL_msg_copy class] forKey:[NSNumber numberWithInt:-530561358]];
        [self.classes setObject:[TL_gzip_packed class] forKey:[NSNumber numberWithInt:812830625]];
        [self.classes setObject:[TL_http_wait class] forKey:[NSNumber numberWithInt:-1835453025]];
        [self.classes setObject:[TL_msgs_state_req class] forKey:[NSNumber numberWithInt:-630588590]];
        [self.classes setObject:[TL_msgs_state_info class] forKey:[NSNumber numberWithInt:81704317]];
        [self.classes setObject:[TL_msgs_all_info class] forKey:[NSNumber numberWithInt:-1933520591]];
        [self.classes setObject:[TL_msg_detailed_info class] forKey:[NSNumber numberWithInt:661470918]];
        [self.classes setObject:[TL_msg_new_detailed_info class] forKey:[NSNumber numberWithInt:-2137147681]];
        [self.classes setObject:[TL_msg_resend_req class] forKey:[NSNumber numberWithInt:2105940488]];
        
        
        
        
        [self.classes setObject:[TL_invokeAfter class] forKey:[NSNumber numberWithInt:-878758099]];
        
        
        //свои консуторы начинаем с 1? но эт не правильно инфа.
        [self.classes setObject:[TL_messageActionEncryptedChat class] forKey:[NSNumber numberWithInt:1]];
        [self.classes setObject:[TL_peerSecret class] forKey:[NSNumber numberWithInt:2]];
        [self.classes setObject:[TL_localMessage class] forKey:[NSNumber numberWithInt:3]];
        [self.classes setObject:[TL_destructMessage class] forKey:[NSNumber numberWithInt:4]];
        [self.classes setObject:[TL_conversation class] forKey:[NSNumber numberWithInt:5]];
        
        
         [self.classes setObject:[TL_inputMessagesFilterAudio class] forKey:[NSNumber numberWithInt:0xcfc87522]];
        
        [self.classes setObject:[TL_outDocument class] forKey:[NSNumber numberWithInt:6]];
        [self.classes setObject:[TL_localMessageService class] forKey:[NSNumber numberWithInt:8]];
        [self.classes setObject:[TL_peerBroadcast class] forKey:[NSNumber numberWithInt:9]];
        [self.classes setObject:[TL_broadcast class] forKey:[NSNumber numberWithInt:10]];
        [self.classes setObject:[TL_messageActionSetMessageTTL class] forKey:[NSNumber numberWithInt:11]];
        [self.classes setObject:[TL_secretServiceMessage class] forKey:[NSNumber numberWithInt:12]];
        
        
        
        for(NSNumber* number in [self.classes allKeys]) {
            [self.constuctors setObject:number forKey:[self.classes objectForKey:number]];
        }
    }
    return self;
}

+ (id)deserialize:(NSData*)data {
    
    if(!data)
        return nil;
    
    SerializedData *stream = [[SerializedData alloc] init];
    NSInputStream *inputStream = [[NSInputStream alloc] initWithData:data];
    [inputStream open];
   // [stream setCacheData:data];
    [stream setInput:inputStream];
    id response = [self TLDeserialize:stream];
    return response;
}

+ (id)constructObject:(NSInputStream *)is {
    SerializedData *stream = [[SerializedData alloc] init];
    [stream setInput:is];
    id response = [self TLDeserialize:stream];
    return response;
}

+ (NSData*)serialize:(TLObject*)obj isCacheSerialize:(bool)isCacheSerialize {
    
    if(!obj)
        return nil;
    
    SerializedData *stream = [[SerializedData alloc] init];
    stream.isCacheSerialize = isCacheSerialize;
    NSOutputStream *outputStream = [[NSOutputStream alloc] initToMemory];
    [outputStream open];
    [stream setOuput:outputStream];
    [self TLSerialize:obj stream:stream];
    return [stream getOutput];
}

+ (NSData*)serialize:(TLObject*)obj {
    return [self serialize:obj isCacheSerialize:YES];
}

+ (void)TLSerialize:(TLObject*)objOrig stream:(SerializedData*)stream {
    
    
    TLObject* obj = objOrig;
    
    Class class = [obj class];
    NSNumber *constructor = [[self instance].constuctors objectForKey:class];
    if(constructor == nil) {
        MTLog(@" Error. Not found constructor for class %@", class);
      //  [NSException raise:@"Error" format:@"Not implemented class %@", NSStringFromClass(class)];
    } else {
        int constructorInt = [constructor intValue];
//        TLog("@ constructor %d find by class %@", constructorInt, class);
        [stream writeInt:constructorInt];
        [obj serialize:stream];
    }
}

+ (id)TLDeserialize:(SerializedData*)stream {
    int constructor = [stream readInt];
    return [self _TLDeserialize:stream constructor:constructor];
}

+ (id) _TLDeserialize:(SerializedData *) stream constructor:(int)constructor {
    Class class = [[self instance].classes objectForKey:[NSNumber numberWithInt:constructor]];
    if(class == nil) {
        if(constructor == 481674261) {
            return [self deserializeVector:stream];
        }
        MTLog(@"Error, constructor %d not found, return nil", constructor);
        return nil;
    } else {
        //TLog("@ create class %@ with constructor %d", class, constructor);
    }
    
    TLObject* object = [[class alloc] init];
    [object unserialize:stream];
    return object;
}

+(id)deserializeVector:(SerializedData *)stream {
    NSMutableArray *vector = [[NSMutableArray alloc] init];
    int count = [stream readInt];
    for(int i = 0; i < count; i++) {
        //Очень фикс, потому что может быть Long, или прочая хуета
        int constructor = [stream readInt];
        Class class = [[self instance].classes objectForKey:[NSNumber numberWithInt:constructor]];
        if(class == nil) {
            [vector addObject:[NSNumber numberWithInt:constructor]];
        } else {
            id obj = [self _TLDeserialize:stream constructor:constructor];
            [vector addObject:obj];
        }
    }
    return vector;
}


+ (SerializedData*)streamWithConstuctor:(int)constructor {
    SerializedData* stream = [[SerializedData alloc] init];
    NSOutputStream *outputStream = [[NSOutputStream alloc] initToMemory];
    [outputStream open];
    [stream setOuput:outputStream];
    [stream writeInt:0xda9b0d0d]; //invokeWithLayer
    [stream writeInt:28];

    [stream writeInt:constructor];
    
    return stream;
}

+ (TLClassStore*)instance {
    static TLClassStore *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TLClassStore alloc] init];
    });
    return instance;
}

@end



@implementation RpcLayer

@end
