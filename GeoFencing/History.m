//
//  History.m
//  GeoFencing
//
//  Created by Venkata Maniteja on 2015-05-14.
//  Copyright (c) 2015 Venkata Maniteja. All rights reserved.
//

#import "History.h"
#import "FMResultSet.h"
#import "FMDatabase.h"

@interface History ()

@property (nonatomic,strong) NSMutableArray *list;
@property (nonatomic,strong) FMDatabase *db;


@end

@implementation History

@synthesize list,db;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    

    list=[[NSMutableArray alloc]init];
    db = [FMDatabase databaseWithPath:[self dataBasePath]];
    
    [db open];
    
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM GEO_HIST"];
    
    if (!rs) {
        NSLog(@"%s: executeQuery failed: %@", __FUNCTION__, [db lastErrorMessage]);
        return;
    }
    
    while ([rs next]) {
        NSString *fieldDatainDB = [rs stringForColumn:@"TIME_HIST"];
        NSLog(@"time stamp = %@", fieldDatainDB);
        [list addObject:fieldDatainDB];
    } //else {
    //        NSLog(@"%s: No record found", __FUNCTION__);
    //    }
    
    [rs close];
    [db close];

    
}



-(NSString *) dataBasePath{
    
    // Get the documents directory
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    
    // Build the path to the database file
    
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"GeoFence.db"]];
    
    //  NSError *error = nil;
    // [[NSFileManager defaultManager] removeItemAtPath:databasePath error:&error];
    
    
    
    NSLog(@"DB Path: %@", databasePath);
    
    return databasePath;
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return list.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"History" forIndexPath:indexPath];
    
    cell.textLabel.text=[list objectAtIndex:indexPath.row];
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        [self deleteFromDatabase:indexPath];
        [list removeObjectAtIndex:indexPath.row];

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-(void)deleteFromDatabase:(NSIndexPath *)indexpath{
    
    [db open];
    [db executeUpdate:@"DELETE FROM GEO_HIST WHERE TIME_HIST =(?)",[list objectAtIndex:indexpath.row]];
    [db close];
   
    
}
/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
