#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, MPMediaPickerControllerDelegate>
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *artistLabel;
@property (nonatomic, strong) UIButton *playPauseButton;
@property (nonatomic, strong) MPMusicPlayerController *player;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.player = [MPMusicPlayerController systemMusicPlayer];

    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 568.0)];
    UIViewController *controller = [[UIViewController alloc] init];
    controller.view.backgroundColor = [UIColor colorWithRed:0.07 green:0.08 blue:0.09 alpha:1.0];
    self.window.rootViewController = controller;

    [self buildInterfaceInView:controller.view controller:controller];
    [self.window makeKeyAndVisible];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(nowPlayingChanged:)
                                                 name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                               object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateChanged:)
                                                 name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                               object:self.player];
    [self.player beginGeneratingPlaybackNotifications];
    [self updateNowPlayingLabels];
    [self updatePlayPauseTitle];

    return YES;
}

- (void)buildInterfaceInView:(UIView *)view controller:(UIViewController *)controller {
    (void)controller;
    UILabel *appTitle = [[UILabel alloc] init];
    appTitle.translatesAutoresizingMaskIntoConstraints = NO;
    appTitle.text = @"Music Player";
    appTitle.textColor = [UIColor whiteColor];
    appTitle.font = [UIFont boldSystemFontOfSize:30.0];
    [view addSubview:appTitle];

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:22.0];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = 2;
    [view addSubview:self.titleLabel];

    self.artistLabel = [[UILabel alloc] init];
    self.artistLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.artistLabel.textColor = [UIColor colorWithWhite:0.72 alpha:1.0];
    self.artistLabel.font = [UIFont systemFontOfSize:16.0];
    self.artistLabel.textAlignment = NSTextAlignmentCenter;
    self.artistLabel.numberOfLines = 2;
    [view addSubview:self.artistLabel];

    UIButton *pickButton = [self buttonWithTitle:@"Choose Songs"];
    pickButton.translatesAutoresizingMaskIntoConstraints = NO;
    [pickButton addTarget:self action:@selector(openPicker:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:pickButton];

    UIButton *previousButton = [self buttonWithTitle:@"Prev"];
    previousButton.translatesAutoresizingMaskIntoConstraints = NO;
    [previousButton addTarget:self action:@selector(previousTrack:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:previousButton];

    self.playPauseButton = [self buttonWithTitle:@"Play"];
    self.playPauseButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.playPauseButton addTarget:self action:@selector(togglePlayback:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.playPauseButton];

    UIButton *nextButton = [self buttonWithTitle:@"Next"];
    nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    [nextButton addTarget:self action:@selector(nextTrack:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:nextButton];

    UILabel *volumeLabel = [[UILabel alloc] init];
    volumeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    volumeLabel.text = @"Volume";
    volumeLabel.textColor = [UIColor colorWithWhite:0.72 alpha:1.0];
    volumeLabel.font = [UIFont systemFontOfSize:14.0];
    [view addSubview:volumeLabel];

    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    volumeView.translatesAutoresizingMaskIntoConstraints = NO;
    volumeView.showsRouteButton = NO;
    [view addSubview:volumeView];

    NSDictionary *views = @{
        @"appTitle": appTitle,
        @"titleLabel": self.titleLabel,
        @"artistLabel": self.artistLabel,
        @"pickButton": pickButton,
        @"previousButton": previousButton,
        @"playPauseButton": self.playPauseButton,
        @"nextButton": nextButton,
        @"volumeLabel": volumeLabel,
        @"volumeView": volumeView
    };

    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[appTitle]-24-|"
                                                                  options:0 metrics:nil views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[titleLabel]-24-|"
                                                                  options:0 metrics:nil views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[artistLabel]-24-|"
                                                                  options:0 metrics:nil views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[pickButton]-24-|"
                                                                  options:0 metrics:nil views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[previousButton]-12-[playPauseButton(==previousButton)]-12-[nextButton(==previousButton)]-24-|"
                                                                  options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[volumeLabel]-24-|"
                                                                  options:0 metrics:nil views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[volumeView]-24-|"
                                                                  options:0 metrics:nil views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[appTitle]-74-[titleLabel]-10-[artistLabel]-56-[pickButton(48)]-20-[previousButton(48)]-42-[volumeLabel]-8-[volumeView]"
                                                                  options:0 metrics:nil views:views]];
}

- (UIButton *)buttonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    button.backgroundColor = [UIColor colorWithRed:0.13 green:0.45 blue:0.78 alpha:1.0];
    button.layer.cornerRadius = 6.0;
    return button;
}

- (void)openPicker:(id)sender {
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    picker.delegate = self;
    picker.allowsPickingMultipleItems = YES;
    picker.prompt = @"Choose songs to play";
    [self.window.rootViewController presentViewController:picker animated:YES completion:nil];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    [self.player setQueueWithItemCollection:mediaItemCollection];
    [self.player play];
    [self updateNowPlayingLabels];
    [self updatePlayPauseTitle];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)togglePlayback:(id)sender {
    if (self.player.playbackState == MPMusicPlaybackStatePlaying) {
        [self.player pause];
    } else {
        [self.player play];
    }
    [self updatePlayPauseTitle];
}

- (void)previousTrack:(id)sender {
    [self.player skipToPreviousItem];
}

- (void)nextTrack:(id)sender {
    [self.player skipToNextItem];
}

- (void)nowPlayingChanged:(NSNotification *)notification {
    [self updateNowPlayingLabels];
}

- (void)playbackStateChanged:(NSNotification *)notification {
    [self updatePlayPauseTitle];
}

- (void)updateNowPlayingLabels {
    MPMediaItem *item = self.player.nowPlayingItem;
    NSString *title = [item valueForProperty:MPMediaItemPropertyTitle];
    NSString *artist = [item valueForProperty:MPMediaItemPropertyArtist];
    self.titleLabel.text = title.length ? title : @"No song selected";
    self.artistLabel.text = artist.length ? artist : @"Choose songs from your music library";
}

- (void)updatePlayPauseTitle {
    NSString *title = self.player.playbackState == MPMusicPlaybackStatePlaying ? @"Pause" : @"Play";
    [self.playPauseButton setTitle:title forState:UIControlStateNormal];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self.player endGeneratingPlaybackNotifications];
}

@end

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
