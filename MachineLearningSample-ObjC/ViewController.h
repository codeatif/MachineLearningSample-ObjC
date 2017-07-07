//
//  ViewController.h
//  MachineLearningSample-ObjC
//
//  Created by Atif Imran on 7/7/17.
//  Copyright © 2017 Atif Imran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) unsigned long resultsCount;
@property (retain, nonatomic) NSArray *results;

@property (weak, nonatomic) IBOutlet UIImageView *sourceImgView;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UITableView *resultsTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progressView;

- (IBAction)useCamera:(id)sender;
- (IBAction)useGallery:(id)sender;

@end

