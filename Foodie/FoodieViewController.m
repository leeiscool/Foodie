//
//  FoodieViewController.m
//  Foodie
//
//  Created by WangYing on 3/24/16.
//  Copyright (c) 2016 WangYing. All rights reserved.
//

#import "FoodieViewController.h"

@interface FoodieViewController ()<UIImagePickerControllerDelegate>

@property (strong,nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong,nonatomic) RestaurantEntity *localRestaurantEntity;

@property (weak, nonatomic) IBOutlet UILabel *titleField;
@property (weak, nonatomic) IBOutlet UILabel *detailsField;
@property (weak, nonatomic) IBOutlet UILabel *rateField;
@property (weak, nonatomic) IBOutlet UIDatePicker *dueDateField;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageField;


@property (nonatomic,assign) BOOL wasDeleted;
@property (nonatomic,assign) BOOL imageAdded;
@end

@implementation FoodieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageAdded = NO;
}


- (IBAction)trashTapped:(id)sender {
    self.wasDeleted = YES;
    [self.managedObjectContext deleteObject:self.localRestaurantEntity];
    [self saveMyRestaurantEntity];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//- (IBAction)prioTapped:(id)sender {
//    self.localRestaurantEntity.restaurantprio =  [NSString stringWithFormat:@"%ld", (long)self.prioField.selectedSegmentIndex] ;
//}

- (IBAction)addImageTapped:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Adding a picture" message:@"Take a photo or choose from library" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * camera = [UIAlertAction actionWithTitle:@"Camera" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.camera;
    }];
    UIAlertAction * library =[UIAlertAction actionWithTitle:@"Library" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.library;
    }];
    UIAlertAction * cancel =[UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleDefault handler:nil];
    [alert addAction:camera];
    [alert addAction:library];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)camera {
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //Permetto la modifica delle foto
    picker.allowsEditing = YES;
    //Imposto il delegato
    [picker setDelegate:self];
    
    [self presentModalViewController:picker animated:YES];
}
- (void)library {
    //Inizializzo la classe per la gestione della libreria immagine
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //Permetto la modifica delle foto
    picker.allowsEditing = YES;
    //Imposto il delegato
    [picker setDelegate:self];
    [self presentModalViewController:picker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *pickedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(pickedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }

    NSLog([NSString stringWithFormat:@"%@", pickedImage.imageAsset ]);
    NSLog(pickedImage.description);
    NSLog([NSString stringWithFormat:@"%@", pickedImage]);
//    [pickedImage initWithCGImage:0x7ff57d103a00 scale:1.0 orientation:0];
    [self.imageField setImage:pickedImage];
    
    self.imageAdded = YES;
    [self saveMyRestaurantEntity];
    [self dismissModalViewControllerAnimated:YES];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{}


- (void) saveMyRestaurantEntity{
    if (self.titleField.text != nil) {
        NSError *err;
        BOOL saveSuccess = [self.managedObjectContext save:&err];
        if (!saveSuccess){
            @throw [NSException exceptionWithName:NSGenericException reason:@"Couldn't save" userInfo:@{NSUnderlyingErrorKey:err}];
        }
    }
}

- (void) textViewDidEndEditing: (NSNotification *)notification{
    if ([notification object] == self)
    {
        self.localRestaurantEntity.restaurantDetails = self.detailsField.text;
        [self saveMyRestaurantEntity];
    }
}

- (void) viewWillAppear:(BOOL)animated{
    //setUp Delet state
    self.wasDeleted = NO;
    
    
    //SetUp Form
    self.titleField.text = self.localRestaurantEntity.restaurantTitle;
    self.detailsField.text = self.localRestaurantEntity.restaurantDetails;
    self.rateField.text = [NSString stringWithFormat:@"Rate: %@",self.localRestaurantEntity.restaurantRate];

//    [self.prioField setSelectedSegmentIndex: [self.localRestaurantEntity.restaurantprio integerValue]];
    
    if (self.imageAdded ==NO && self.localRestaurantEntity.restaurantPic != nil) {
        self.imageField.image = [UIImage imageWithData: self.localRestaurantEntity.restaurantPic];
    }
    
    NSDate *dueDate = self.localRestaurantEntity.restaurantDueDate;
    if (dueDate != nil) {
        [self.dueDateField setDate:dueDate];
    }
    //Detect edit ends
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidEndEditing:) name:UITextViewTextDidEndEditingNotification object:self];
}


- (void) viewWillDisappear:(BOOL)animated{
    if (self.wasDeleted == NO) {
        //Save everything
        self.localRestaurantEntity.restaurantTitle = self.titleField.text;
        self.localRestaurantEntity.restaurantDetails = self.detailsField.text;
        self.localRestaurantEntity.restaurantDueDate = self.dueDateField.date;
//        self.localRestaurantEntity.restaurantprio =  [NSString stringWithFormat:@"%ld",(long)self.prioField.selectedSegmentIndex];
        if (self.imageAdded == YES) {
            self.localRestaurantEntity.restaurantPic = UIImageJPEGRepresentation(self.imageField.image, 1.0) ;
        }
        [self saveMyRestaurantEntity];
    }
    //Remove detection
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:UITextViewTextDidEndEditingNotification object:self];
}


- (IBAction)dueDateEditted:(id)sender {
    self.localRestaurantEntity.restaurantDueDate = self.dueDateField.date;
    [self saveMyRestaurantEntity];
}

- (IBAction)titleFieldEditted:(id)sender {
    self.localRestaurantEntity.restaurantTitle =self.titleField.text;
    [self saveMyRestaurantEntity];
}



- (void) receiveMOC:(NSManagedObjectContext *)incomingMOC{
    self.managedObjectContext = incomingMOC;
    
}

- (void) receiveRestaurantEntity:(RestaurantEntity *) incomingRestaurantEntity{
    self.localRestaurantEntity = incomingRestaurantEntity;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
