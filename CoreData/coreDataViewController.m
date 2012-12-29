//
//  coreDataViewController.m
//  CoreData
//
//  Created by David Au on 12-03-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "coreDataViewController.h"
#import "coreDataAppDelegate.h"

@implementation coreDataViewController

@synthesize name, address, phone, status, myTextView;

// save the data
- (void) saveData {
    coreDataAppDelegate *appDelegate = 
    [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    
    NSManagedObject *newContact;
    newContact = [NSEntityDescription
                  insertNewObjectForEntityForName:@"Contacts"
                  inManagedObjectContext:context];
    [newContact setValue:name.text forKey:@"name"];
    [newContact setValue:address.text forKey:@"address"];
    [newContact setValue:phone.text forKey:@"phone"];
    name.text = @"";
    address.text = @"";
    phone.text = @"";
    
    NSError *error;
    [context save:&error];
    status.text = @"Contact saved";    
}

//find the data
- (void) findContact {
    coreDataAppDelegate *appDelegate = 
    [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = 
    [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc = 
    [NSEntityDescription entityForName:@"Contacts" 
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred = 
    [NSPredicate predicateWithFormat:@"(name = %@)", 
     name.text];
    [request setPredicate:pred];
    
    NSManagedObject *matches = nil;
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request 
                                              error:&error];
    NSString *myText = [[NSString alloc]init];
    myTextView.text = @"";
    for (matches in objects) {
        myText = [NSString stringWithFormat:@"name:%@--address%@----phone:%@ \n",
              [matches valueForKey:@"name"],
              [matches valueForKey:@"address"],
              [matches valueForKey:@"phone"]];
        myTextView.text = [myTextView.text stringByAppendingString:myText];
    }
    
    if ([objects count] == 0) {
        status.text = @"No matches";
    } else {
        matches = [objects objectAtIndex:0];
        address.text = [matches valueForKey:@"address"];
        phone.text = [matches valueForKey:@"phone"];
        status.text = [NSString stringWithFormat:
                       @"%d matches found", [objects count]];
    }
}

//delete data
- (void) deleteContact
{
    coreDataAppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Contacts"
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    //finde the data
    NSPredicate *pred =
    [NSPredicate predicateWithFormat:@"(name = %@)",
     name.text];
    [request setPredicate:pred];
    
    NSManagedObject *matches = nil;
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];
    int findCount = [objects count];
    //delete the data
    for (matches in objects) {
        [context deleteObject:matches];
    }
    
    //save the changes
    if (findCount != 0) {
        if (![context save:&error]) {
            UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"error!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [messageAlert show];
            NSLog(@"error!");
        }else {
            UIAlertView *okAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"delete ok.!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [okAlert show];
            NSLog(@"save person ok.");
        }
    } else {
        UIAlertView *noAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"not find!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [noAlert show];
        NSLog(@"not find!");
    }
    
    
}

//
//// use to hide the keyboard  return
//-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
//{
//    if ([text isEqualToString:@"\n"]) {
//        [textView resignFirstResponder];
//        return NO;
//    }
//    return YES;
//}

//uset to hiden the keyboard when touch anywhere
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [name resignFirstResponder];
    [address resignFirstResponder];
    [phone resignFirstResponder];
    
    [super touchesBegan:touches withEvent:event];
}

- (IBAction)deleteButton:(id)sender {
    //deleteButton to delete the find data
    [self deleteContact];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == name || textField == address || textField == phone) {
        [name resignFirstResponder];
        [address resignFirstResponder];
        [phone resignFirstResponder];
    }
    
    return YES;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [name setDelegate:self];
    [address setDelegate:self];
    [phone setDelegate:self];
    [myTextView setEditable:NO];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setMyTextView:nil];
    [self setDeleteButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.name = nil;
    self.address = nil;
    self.phone = nil;
    self.status = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
