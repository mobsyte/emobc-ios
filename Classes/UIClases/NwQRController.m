/**
 *  Copyright 2012 Neurowork Consulting S.L.
 *
 *  This file is part of eMobc.
 *
 *  eMobcViewController.m
 *  eMobc IOS Framework
 *
 *  eMobc is free software: you can redistribute it and/or modify
 *  it under the terms of the Affero GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  eMobc is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the Affero GNU General Public License
 *  along with eMobc.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import "NwQRController.h"
#import "ZBarSDK.h"
#import "eMobcViewController.h"
#import "NwButton.h"
#import "AppFormatsStyles.h"
#import "AppStyles.h"


@implementation NwQRController

//Datos parseados del fichero qr.xml
@synthesize data;

@synthesize resultImage;
@synthesize resultText;

@synthesize sizeTop;
@synthesize sizeBottom;
@synthesize sizeHeaderText;

@synthesize scanButton;
@synthesize imageSize;

@synthesize varStyles;
@synthesize varFormats;
@synthesize background;


/**
 * Called after the controller’s view is loaded into memory.
 */
- (void)viewDidLoad {
	[super viewDidLoad];

	loadContent = FALSE;
	
	varStyles = [mainController.theStyle.stylesMap objectForKey:data.levelId];
	
	if (varStyles == nil) {
		varStyles = [mainController.theStyle.stylesMap objectForKey:@"QR_ACTIVITY"];
	}else if(varStyles == nil){
		varStyles = [mainController.theStyle.stylesMap objectForKey:@"DEFAULT"];
	}
	
	if(varStyles != nil) {
		[self loadThemes];
	}	
	
	[self createImageView];
	[self createScanButton];
	[self createTextView];
	

}


-(void) createImageView{
	if([eMobcViewController isIPad]){
		if([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight){
			resultImage = [[[UIImageView alloc] initWithFrame:CGRectMake(128, sizeTop + sizeHeaderText, 768, 400)] autorelease];
			sizeTop += 400;
		}else{
			resultImage = [[[UIImageView alloc] initWithFrame:CGRectMake(0, sizeTop + sizeHeaderText, 768, 400)] autorelease];
			sizeTop += 400;
		}				
	}else {
		if([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight){
			resultImage = [[[UIImageView alloc] initWithFrame:CGRectMake(0, sizeTop + sizeHeaderText, 240, 320 - sizeTop - sizeBottom - sizeHeaderText)] autorelease];
		}else{
			resultImage = [[[UIImageView alloc] initWithFrame:CGRectMake(0, sizeTop + sizeHeaderText, 320, 180)] autorelease];
			sizeTop += 180;
		}				
	}
	
	[self.view addSubview:resultImage];
}


-(void) createScanButton {
	imageSize = [[UIImageView alloc] init];
	//create the button
	scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
		
	NSString *k = [eMobcViewController whatDevice:k];
	
	NSString *imagePath = [[NSBundle mainBundle] pathForResource:data.scanImage ofType:nil inDirectory:k];
	
	[scanButton setImage:[UIImage imageWithContentsOfFile:imagePath] forState:UIControlStateNormal];
	
	imageSize.image = [UIImage imageWithContentsOfFile:imagePath];
	
	int width,height;
	
	if(![data.scanImage isEqualToString:@""] && data.scanImage != nil){
		width = imageSize.image.size.width;
		height = imageSize.image.size.height;
	}else{
		width = 200;
		height = 45;
	}
	
	//set the position of the button
	if([eMobcViewController isIPad]){
		if([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight){
			if(width > 200 || height > 45){
				scanButton.frame = CGRectMake(650, 768 - sizeBottom - 50, 200, 45);
			}else{
				scanButton.frame = CGRectMake(512 + (512 - width)/2, 768 - sizeBottom - height - 10, width, height);
			}
		}else{
			if(width > 200 || height > 45){
				scanButton.frame = CGRectMake(284, 1024 - sizeBottom - 50, 200, 45);
			}else{
				scanButton.frame = CGRectMake((768 - width)/2, 1024 - sizeBottom - height - 10, width, height);
			}
		}	
		sizeBottom += 55;
	}else {
		if([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight){
			if(width > 200 || height > 45){
				scanButton.frame = CGRectMake(260, 320 - sizeBottom - 50, 200, 45);
			}else{
				scanButton.frame = CGRectMake(260 + (260 - width)/2, 320 - sizeBottom - height - 10, width, height);
			}
		}else{
			if(width > 200 || height > 45){
				scanButton.frame = CGRectMake(60, 480 - sizeBottom - 50, 200, 45);
			}else{
				scanButton.frame = CGRectMake((320 - width)/2, 480 - sizeBottom - height - 10, width, height);
			}
		}
		sizeBottom += 55;
	}
	
	if([data.scanImage isEqualToString:@""] || data.scanImage == nil){
		//set the button's title
		[scanButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[scanButton setTitle:@"Scan" forState:UIControlStateNormal];
		
	}
	
	scanButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
	scanButton.adjustsImageWhenHighlighted = NO;
	
	//listen for clicks
	[scanButton addTarget:self action:@selector(scanButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	
			
	//add the button to the view
	[self.view addSubview:scanButton];
}


-(void) createTextView{
	if([eMobcViewController isIPad]){
		if([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight){
			resultText = [[[UITextView alloc] initWithFrame:CGRectMake(5, sizeTop + sizeHeaderText, 520, 768 - sizeTop - sizeBottom - sizeHeaderText)] autorelease];
		}else{
			resultText = [[[UITextView alloc] initWithFrame:CGRectMake(0, sizeTop + sizeHeaderText, 768, 1024 - sizeTop - sizeBottom - sizeHeaderText)] autorelease];
		}				
	}else {
		if([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight){
			resultText = [[[UITextView alloc] initWithFrame:CGRectMake(240, sizeTop + sizeHeaderText, 240, 320 - sizeTop - sizeBottom - sizeHeaderText - 50)] autorelease];
		}else{
			resultText = [[[UITextView alloc] initWithFrame:CGRectMake(0, sizeTop + sizeHeaderText, 320, 480 - sizeTop - sizeBottom - sizeHeaderText)] autorelease];
		}				
	}
	[resultText setEditable:NO];
	[resultText setText:@"No barcode scanned..."];
	
	[self.view addSubview:resultText];
} 


/**
 * Sent to the view controller when the application receives a memory warning
 */
-(void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


/**
 * Called when the controller’s view is released from memory.
 */
- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


/**
 * scan QR code when button is pressed
 *
 * @see ZBarSDK
 */
- (void) scanButtonTapped {
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
	
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
	
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
	
    // present and release the controller
    [self presentModalViewController: reader
                            animated: YES];
    [reader release];
}

/**
 * Tell delegate that User has choosen a static image o film
 *
 * @param reader Controller handle inteface object from image selector
 * @param info Diccionary which has original image and original one
 *
 */
-(void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info {
    // ADD: get the decode results
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
	
    // EXAMPLE: do something useful with the barcode data
	resultText.text = symbol.data;
	
    // EXAMPLE: do something useful with the barcode image
	resultImage.image = [info objectForKey: UIImagePickerControllerOriginalImage];
		
	int count = [data.qrs count];
	
	for(int i=0; i < count; i++) {
		
		AppQrs* theQrs = [data.qrs objectAtIndex:i];
		
		if([resultText.text isEqualToString:theQrs.idQr]){
			NextLevel* listNL = [[NextLevel alloc] initWithData:theQrs.nextLevel.levelId dataId:theQrs.nextLevel.dataId];
			[mainController loadNextLevel:listNL];
		}
	}
    	
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissModalViewControllerAnimated: YES];
}

/**
 * Load themes from xml into components
 */
-(void)loadThemesComponents {
	
	for(int x = 0; x < varStyles.listComponents.count; x++){
		NSString *var = [varStyles.listComponents objectAtIndex:x];
		
		NSString *type = [varStyles.mapFormatComponents objectForKey:var];
		
		varFormats = [mainController.theFormat.formatsMap objectForKey:type];
		UILabel *myLabel;
		
		if([var isEqualToString:@"header"]){
			if([eMobcViewController isIPad]){
				if([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight){
					myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, sizeTop, 1024, 20)];	
				}else{
					myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, sizeTop, 768, 20)];
				}				
			}else {
				if([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight){
					myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, sizeTop, 480, 20)];	
				}else{
					myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, sizeTop, 320, 20)];
				}				
			}
			
			myLabel.text = data.headerText;
			
			int varSize = [varFormats.textSize intValue];
			
			myLabel.font = [UIFont fontWithName:varFormats.typeFace size:varSize];
			myLabel.backgroundColor = [UIColor clearColor];
			
			myLabel.textColor = [UIColor blackColor];
			myLabel.textAlignment = UITextAlignmentCenter;
			
			[self.view addSubview:myLabel];
			[myLabel release];
		}
	}
}


/**
 * Load themes
 */
-(void) loadThemes {
	
	sizeTop = 0;
	sizeBottom = 0;
	sizeHeaderText = 25;
	
	sizeTop = [mainController ifMenuAndAdsTop:sizeTop];
	sizeBottom = [mainController ifMenuAndAdsBottom:sizeBottom];
	
	if(![varStyles.backgroundFileName isEqualToString:@""]) {
		
		if([eMobcViewController isIPad]){
			if([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight){
				background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
			}else{
				background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
			}				
		}else {
			if([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight){
				background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
			}else{
				background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
			}				
		}
		
		NSString *k = [eMobcViewController whatDevice:k];
		
		NSString *imagePath = [[NSBundle mainBundle] pathForResource:varStyles.backgroundFileName ofType:nil inDirectory:k];
		
		background.image = [UIImage imageWithContentsOfFile:imagePath];
		
		[self.view addSubview:background];
		[self.view sendSubviewToBack:background];
	}else{
		self.view.backgroundColor = [UIColor whiteColor];
	}
	
	if(![varStyles.components isEqualToString:@""]) {
		NSArray *separarComponents = [varStyles.components componentsSeparatedByString:@";"];
		NSArray *assignment;
		NSString *component;
		
		for(int i = 0; i < separarComponents.count - 1; i++){
			assignment = [[separarComponents objectAtIndex:i] componentsSeparatedByString:@"="];
			
			component = [assignment objectAtIndex:0];
			NSString *format = [assignment objectAtIndex:1];
			
			//[varStyles.mapFormatComponents setObject:component forKey:format];
			[varStyles.mapFormatComponents setObject:format forKey:component];
			
			if(![component isEqual:@"selection_list"]){
				[varStyles.listComponents addObject:component];
			}else{
				varStyles.selectionList = format;
			}
		}
		[self loadThemesComponents];
	}
}


/**
 * Returns a Boolean value indicating whether the view controller supports the specified orientation.
 *
 * @param orient The orientation of the application’s user interface after the rotation. 
 * The possible values are described in UIInterfaceOrientation.
 *
 * @return YES if the view controller supports the specified orientation or NO if it does not
 */
- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) orient {
    return YES;
}


-(void) orientationChanged:(NSNotification *)object{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	if(orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown || currentOrientation == orientation ){
		return;
	}
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(relayoutLayers) object: nil];
	
	currentOrientation = orientation;
	
	[self performSelector:@selector(orientationChangedMethod) withObject: nil afterDelay: 0];
}

-(void) orientationChangedMethod{
	
	if([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight){
		self.view = self.landscapeView;
	}else{
		self.view = self.portraitView;
	}
	
	if(loadContent == FALSE){
		loadContent = TRUE;
			
		if(![mainController.appData.topMenu isEqualToString:@""]){
			[self callTopMenu];
		}
		if(![mainController.appData.bottomMenu isEqualToString:@""]){
			[self callBottomMenu];
		}
		
		//publicity
		if([mainController.appData.banner isEqualToString:@"admob"]){
			[self createAdmobBanner];
		}else if([mainController.appData.banner isEqualToString:@"yoc"]){
			[self createYocBanner];
		}
		
		[self createImageView];
		[self createScanButton];
		[self createTextView];
		
		if(varStyles != nil) {
			[self loadThemes];
		}
	}
}


- (void) dealloc {
    self.resultImage = nil;
    self.resultText = nil;
	
	[resultImage release];
	[resultText release];
	
    [super dealloc];
}

@end