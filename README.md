# YARBS

> Yet Another Rsync Backup Script

## Overview

This script provides a robust solution for performing incremental backups on most unix-like systems, mimicking the functionality of Apple's TimeMachine. It supports various backup frequencies, including yearly, monthly, weekly, daily, and hourly. The script is designed for flexibility, allowing customization of source and destination paths, exclusion of specific paths and file extensions, and a dry run option for testing.

### Features

* Incremental Backups: Efficiently backs up files, only copying changes.
* Flexible Backup Intervals: Supports yearly, monthly, weekly, daily, and hourly backups.
* Customizable Paths: Set custom source and backup paths.
* Exclusion Options: Exclude specific paths and file extensions from the backup.
* File Size Limit: Exclude files larger than a specified size from the backup.
* Dry Run Mode: Test the script without performing actual backups.

## Requirements

* Fedora Linux (or similar Unix-like system).
* rsync installed on the system.
* Sufficient permissions to access and write to the source and backup directories.

## Installation

Copy the backup_script.sh to your desired location.
Make the script executable:

```
chmod +x backup_script.sh
```

## Usage

### Command-Line Options

```
-s: Set the source directory.
-b: Set the backup directory.
-p: Define paths to exclude.
-e: Specify file extensions to exclude.
-l: Set the maximum file size (in MB) for files to be included in the backup. 0 is no limit (default).
-d: Disable dry run for a real backup.
```

### Basic Command

To run the backup with default settings:

```
./backup_script.sh
```

### Custom Options

Custom Source Directory:

```
./backup_script.sh -s /path/to/your/source
```

### Custom Backup Directory:

```
./backup_script.sh -b /path/to/backup/dir
```

### Skip Specific Paths:

```
./backup_script.sh -p "/path/to/skip1 /path/to/skip2"
```

### Skip Specific File Extensions:

```
./backup_script.sh -e "ext1 ext2"
```

### Perform Real Backup (Disable Dry Run):

```
./backup_script.sh -d
```

### Using File Size Limit

To exclude files larger than a certain size (e.g., 500 MB):

```
./backup_script.sh -l 500
```
**Note on File Size Limit**

* The limit option is particularly useful for excluding large files that may not require frequent backups or may consume excessive storage space.
* This feature enhances backup efficiency and storage management.

## Testing

Before deploying in a production environment, test the script in a controlled setting. Use the dry run option (-d) to simulate backups without making changes.
Automation

For automated backups, consider setting up a cron job to execute this script at regular intervals.

```
0 * * * * /path/to/backup_script.sh
```
