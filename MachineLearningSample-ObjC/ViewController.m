//
//  ViewController.m
//  MachineLearningSample-ObjC
//
//  Created by Atif Imran on 7/7/17.
//  Copyright © 2017 Atif Imran. All rights reserved.
//

#import "ViewController.h"

#import <CoreML/CoreML.h>
#import <Vision/Vision.h>

#import "Inceptionv3.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.resultsTableView registerClass:UITableViewCell.self forCellReuseIdentifier: @"cell"];
}

- (void) processImage: (CIImage *)image {
    [self.progressView startAnimating];
    MLModel *model = [[[Inceptionv3 alloc] init] model];
    VNCoreMLModel *m = [VNCoreMLModel modelForMLModel: model error:nil];
    VNCoreMLRequest *req = [[VNCoreMLRequest alloc] initWithModel: m completionHandler: (VNRequestCompletionHandler) ^(VNRequest *request, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressView stopAnimating];
            self.resultsCount = request.results.count;
            self.results = [request.results copy];
            VNClassificationObservation *topResult = ((VNClassificationObservation *)(self.results[0]));
            float percent = topResult.confidence * 100;
            self.resultLabel.text = [NSString stringWithFormat: @"Confidence: %.f%@ %@", percent,@"%", topResult.identifier];
            [self.resultsTableView reloadData];
        });
    }];
    
    NSDictionary *options = [[NSDictionary alloc] init];
    NSArray *reqArray = @[req];
    
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCIImage:image options:options];
    dispatch_async(dispatch_get_main_queue(), ^{
        [handler performRequests:reqArray error:nil];
    });
}

# pragma mark Face Recognition

- (void)drawFaceRect:(CIImage*)image{
    //face landmark
    VNDetectFaceLandmarksRequest *faceLandmarks = [VNDetectFaceLandmarksRequest new];
    VNSequenceRequestHandler *faceLandmarksDetectionRequest = [VNSequenceRequestHandler new];
    [faceLandmarksDetectionRequest performRequests:@[faceLandmarks] onCIImage:image error:nil];
    for(VNFaceObservation *observation in faceLandmarks.results){
        //draw rect on face
        CGRect boundingBox = observation.boundingBox;
        CGSize size = CGSizeMake(boundingBox.size.width * self.sourceImgView.bounds.size.width, boundingBox.size.height * self.sourceImgView.bounds.size.height);
        CGPoint origin = CGPointMake(boundingBox.origin.x * self.sourceImgView.bounds.size.width, (1-boundingBox.origin.y)*self.sourceImgView.bounds.size.height - size.height);
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        
        layer.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
        layer.borderColor = [UIColor redColor].CGColor;
        layer.borderWidth = 2;
        
        [self.sourceImgView.layer addSublayer:layer];
    }
}

- (void)detectFace:(CIImage*)image{
    //create req
    VNDetectFaceRectanglesRequest *faceDetectionReq = [VNDetectFaceRectanglesRequest new];
    NSDictionary *d = [[NSDictionary alloc] init];
    //req handler
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCIImage:image options:d];
    //send req to handler
    [handler performRequests:@[faceDetectionReq] error:nil];
    
    //is there a face?
    for(VNFaceObservation *observation in faceDetectionReq.results){
        if(observation){
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Face Detected!"
                                                                           message:@"I've found a face in there! Show you where I'd found that?"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Show" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      [self drawFaceRect:image];
                                                                  }];
            [alert addAction:defaultAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
    }
}

# pragma mark Image Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *selectedImg = info[UIImagePickerControllerOriginalImage];
    CIImage* image = [[CIImage alloc] initWithCGImage:selectedImg.CGImage];
    
    self.sourceImgView.image = selectedImg;
    self.resultLabel.text = @"Processing image, sit tight!";
    
    //face detection, clear previously drawn detection rectangle
    self.sourceImgView.layer.sublayers = nil;
    [self detectFace:image];
    
    //image processing
    [self processImage: image];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

# pragma mark Image Source

- (IBAction)useCamera:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:NULL];
    }else{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"No camera found!"
                                                                       message:@"Are you on simlulator? Use an actual device or try picking an image from gallery"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)useGallery:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark - TableView Delegate

- (nonnull UITableViewCell *) tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    VNClassificationObservation *observation = ((VNClassificationObservation *)(self.results[indexPath.row]));
    float percent = observation.confidence * 100;
    cell.textLabel.text = [NSString stringWithFormat: @"Confidence: %.f%@ %@", percent,@"%", observation.identifier];
    return cell;
}

- (NSInteger) tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultsCount;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
