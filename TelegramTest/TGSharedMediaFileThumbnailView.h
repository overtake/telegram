
typedef enum {
    TGSharedMediaFileThumbnailViewStyleRounded,
    TGSharedMediaFileThumbnailViewStylePlain
} TGSharedMediaFileThumbnailViewStyle;

@interface TGSharedMediaFileThumbnailView : TMView

- (void)setStyle:(TGSharedMediaFileThumbnailViewStyle)style colors:(NSArray *)colors;

@end
