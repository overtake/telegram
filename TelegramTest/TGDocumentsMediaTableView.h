//
//  TGDocumentsMediaTableView.h
//  Telegram
//
//  Created by keepcoder on 27.01.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMTableView.h"
#import "TGDocumentMediaRowView.h"
@interface TGDocumentsMediaTableView : MessagesTableView
@property (nonatomic,assign) BOOL isProgress;


@property (nonatomic,weak) TMCollectionPageController *collectionViewController;

-(Class)rowViewClass;
-(Class)historyFilter;
-(BOOL)acceptMessageItem:(MessageTableItem *)item;
-(int)heightWithItem:(MessageTableItem *)item;
-(void)prepareItem:(MessageTableItem *)item;

-(void)setConversation:(TL_conversation *)conversation;

-(BOOL)isNeedCap;
-(void)setEditable:(BOOL)editable animated:(BOOL)animated;
-(BOOL)isEditable;

-(BOOL)isSelectedItem:(MessageTableItem *)item;
-(void)setSelected:(BOOL)selected forItem:(MessageTableItem *)item;

-(NSArray *)selectedItems;

-(NSArray *)items;

@end
