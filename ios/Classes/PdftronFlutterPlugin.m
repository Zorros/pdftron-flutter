#import "PdftronFlutterPlugin.h"


@implementation PdftronFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"pdftron_flutter"
            binaryMessenger:[registrar messenger]];
  PdftronFlutterPlugin* instance = [[PdftronFlutterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"getVersion" isEqualToString:call.method]) {
      result([@"PDFNet " stringByAppendingFormat:@"%f", [PTPDFNet GetVersion]]);
  } else if ([@"initialize" isEqualToString:call.method]) {
      NSString *licenseKey = call.arguments[@"licenseKey"];
      [PTPDFNet Initialize:licenseKey];
  } else if ([@"openDocument" isEqualToString:call.method]) {
      NSString *document = call.arguments[@"document"];
      
      if (document == nil || document.length == 0) {
          // error handling
          return;
      }
      
      // Create and wrap a tabbed controller in a navigation controller.
      self.documentViewController = [[PTDocumentViewController alloc] init];
      
      UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.documentViewController];
      
      self.documentViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(topLeftButtonPressed:)];
      
      // Open a file URL.
      NSURL *fileURL = [[NSBundle mainBundle] URLForResource:document withExtension:@"pdf"];
      if ([document containsString:@"://"]) {
          fileURL = [NSURL URLWithString:document];
      } else if ([document hasPrefix:@"/"]) {
          fileURL = [NSURL fileURLWithPath:document];
      }
      
      [self.documentViewController openDocumentWithURL:fileURL];
      
      UIViewController *presentingViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
      
      // Show navigation (and tabbed) controller.
      [presentingViewController presentViewController:navigationController animated:YES completion:nil];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)topLeftButtonPressed:(UIBarButtonItem *)barButtonItem
{
    
    [[UIApplication sharedApplication].delegate.window.rootViewController.presentedViewController dismissViewControllerAnimated:YES completion:Nil];
    
}

@end
