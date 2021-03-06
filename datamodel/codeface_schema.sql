SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

DROP SCHEMA IF EXISTS `codeface` ;
CREATE SCHEMA IF NOT EXISTS `codeface` DEFAULT CHARACTER SET utf8 ;
USE `codeface` ;

-- -----------------------------------------------------
-- Table `codeface`.`project`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`project` ;

CREATE TABLE IF NOT EXISTS `codeface`.`project` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `analysisMethod` VARCHAR(45) NOT NULL,
  `analysisTime` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `name_UNIQUE` ON `codeface`.`project` (`name` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`person`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`person` ;

CREATE TABLE IF NOT EXISTS `codeface`.`person` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NULL DEFAULT NULL,
  `projectId` BIGINT NOT NULL,
  `email1` VARCHAR(255) NOT NULL,
  `email2` VARCHAR(255) NULL DEFAULT NULL,
  `email3` VARCHAR(255) NULL DEFAULT NULL,
  `email4` VARCHAR(255) NULL DEFAULT NULL,
  `email5` VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `person_projectId`
    FOREIGN KEY (`projectId`)
    REFERENCES `codeface`.`project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `person_projectId_idx` ON `codeface`.`person` (`projectId` ASC);

CREATE UNIQUE INDEX `person_email_project_idx` ON `codeface`.`person` (`projectId` ASC, `email1` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`issue`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`issue` ;

CREATE TABLE IF NOT EXISTS `codeface`.`issue` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `bugId` VARCHAR(45) NOT NULL,
  `creationDate` DATETIME NOT NULL,
  `modifiedDate` DATETIME NULL DEFAULT NULL,
  `url` VARCHAR(255) NULL DEFAULT NULL,
  `isRegression` INT(1) NULL DEFAULT 0,
  `status` VARCHAR(45) NOT NULL,
  `resolution` VARCHAR(45) NULL DEFAULT NULL,
  `priority` VARCHAR(45) NOT NULL,
  `severity` VARCHAR(45) NOT NULL,
  `createdBy` BIGINT NOT NULL,
  `assignedTo` BIGINT NULL DEFAULT NULL,
  `projectId` BIGINT NOT NULL,
  `subComponent` VARCHAR(45) NULL DEFAULT NULL,
  `subSubComponent` VARCHAR(45) NULL DEFAULT NULL,
  `version` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `issue_createdBy`
    FOREIGN KEY (`createdBy`)
    REFERENCES `codeface`.`person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `issue_assignedTo`
    FOREIGN KEY (`assignedTo`)
    REFERENCES `codeface`.`person` (`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `issue_projectId`
    FOREIGN KEY (`projectId`)
    REFERENCES `codeface`.`project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `issue_createdBy_idx` ON `codeface`.`issue` (`createdBy` ASC);

CREATE INDEX `issue_assignedTo_idx` ON `codeface`.`issue` (`assignedTo` ASC);

CREATE INDEX `issue_projectId_idx` ON `codeface`.`issue` (`projectId` ASC);

CREATE UNIQUE INDEX `bugId_UNIQUE` ON `codeface`.`issue` (`bugId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`issue_comment`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`issue_comment` ;

CREATE TABLE IF NOT EXISTS `codeface`.`issue_comment` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `who` BIGINT NOT NULL,
  `fk_issueId` BIGINT NOT NULL,
  `commentDate` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_issueId`
    FOREIGN KEY (`fk_issueId`)
    REFERENCES `codeface`.`issue` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `issue_comment_who`
    FOREIGN KEY (`who`)
    REFERENCES `codeface`.`person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `fk_issueId_idx` ON `codeface`.`issue_comment` (`fk_issueId` ASC);

CREATE INDEX `issue_comment_who_idx` ON `codeface`.`issue_comment` (`who` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`release_timeline`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`release_timeline` ;

CREATE TABLE IF NOT EXISTS `codeface`.`release_timeline` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `type` VARCHAR(45) NOT NULL,
  `tag` VARCHAR(45) NOT NULL,
  `date` DATETIME NULL DEFAULT NULL,
  `projectId` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `release_project_ref`
    FOREIGN KEY (`projectId`)
    REFERENCES `codeface`.`project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `release_project_ref_idx` ON `codeface`.`release_timeline` (`projectId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`release_range`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`release_range` ;

CREATE TABLE IF NOT EXISTS `codeface`.`release_range` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `releaseStartId` BIGINT NOT NULL,
  `releaseEndId` BIGINT NOT NULL,
  `projectId` BIGINT NOT NULL,
  `releaseRCStartId` BIGINT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `releaseRange_releaseStartId`
    FOREIGN KEY (`releaseStartId`)
    REFERENCES `codeface`.`release_timeline` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `releaseRange_releaseEndId`
    FOREIGN KEY (`releaseEndId`)
    REFERENCES `codeface`.`release_timeline` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `releaseRange_projectId`
    FOREIGN KEY (`projectId`)
    REFERENCES `codeface`.`project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `releaseRange_RCStartId`
    FOREIGN KEY (`releaseRCStartId`)
    REFERENCES `codeface`.`release_timeline` (`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `releaseRange_releaseStartId_idx` ON `codeface`.`release_range` (`releaseStartId` ASC);

CREATE INDEX `releaseRange_releaseEndId_idx` ON `codeface`.`release_range` (`releaseEndId` ASC);

CREATE INDEX `releaseRange_projectId_idx` ON `codeface`.`release_range` (`projectId` ASC);

CREATE INDEX `releaseRange_RCStartId_idx` ON `codeface`.`release_range` (`releaseRCStartId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`mailing_list`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`mailing_list` ;

CREATE TABLE IF NOT EXISTS `codeface`.`mailing_list` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `projectId` BIGINT NOT NULL,
  `name` VARCHAR(128) NOT NULL,
  `description` VARCHAR(255) NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `mailing_lists_projectid`
    FOREIGN KEY (`projectId`)
    REFERENCES `codeface`.`project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `mailing_lists_projectid_idx` ON `codeface`.`mailing_list` (`projectId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`mail_thread`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`mail_thread` ;

CREATE TABLE IF NOT EXISTS `codeface`.`mail_thread` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `subject` VARCHAR(255) NULL DEFAULT NULL,
  `createdBy` BIGINT NULL DEFAULT NULL,
  `projectId` BIGINT NOT NULL,
  `releaseRangeId` BIGINT NOT NULL,
  `mlId` BIGINT NOT NULL,
  `mailThreadId` BIGINT NOT NULL,
  `creationDate` DATETIME NULL DEFAULT NULL,
  `numberOfAuthors` INT NOT NULL,
  `numberOfMessages` INT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `mail_createdBy`
    FOREIGN KEY (`createdBy`)
    REFERENCES `codeface`.`person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `mail_release_range_key`
    FOREIGN KEY (`releaseRangeId`)
    REFERENCES `codeface`.`release_range` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `mail_projectId`
    FOREIGN KEY (`projectId`)
    REFERENCES `codeface`.`project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `mail_mlId`
    FOREIGN KEY (`mlId`)
    REFERENCES `codeface`.`mailing_list` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `mail_createdBy_idx` ON `codeface`.`mail_thread` (`createdBy` ASC);

CREATE INDEX `mail_projectId_idx` ON `codeface`.`mail_thread` (`projectId` ASC);

CREATE INDEX `mail_release_range_key_idx` ON `codeface`.`mail_thread` (`releaseRangeId` ASC);

CREATE INDEX `mail_mlId_idx` ON `codeface`.`mail_thread` (`mlId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`thread_responses`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`thread_responses` ;

CREATE TABLE IF NOT EXISTS `codeface`.`thread_responses` (
  `who` BIGINT NOT NULL,
  `mailThreadId` BIGINT NOT NULL,
  `mailDate` DATETIME NULL DEFAULT NULL,
  CONSTRAINT `thread_responses_who`
    FOREIGN KEY (`who`)
    REFERENCES `codeface`.`person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `mailThreadId`
    FOREIGN KEY (`mailThreadId`)
    REFERENCES `codeface`.`mail_thread` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `thread_responses_who_idx` ON `codeface`.`thread_responses` (`who` ASC);

CREATE INDEX `mailThreadId_idx` ON `codeface`.`thread_responses` (`mailThreadId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`cc_list`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`cc_list` ;

CREATE TABLE IF NOT EXISTS `codeface`.`cc_list` (
  `issueId` BIGINT NOT NULL,
  `who` BIGINT NOT NULL,
  CONSTRAINT `cclist_issueId`
    FOREIGN KEY (`issueId`)
    REFERENCES `codeface`.`issue` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `cclist_who`
    FOREIGN KEY (`who`)
    REFERENCES `codeface`.`person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `cclist_issueId_idx` ON `codeface`.`cc_list` (`issueId` ASC);

CREATE INDEX `cclist_who_idx` ON `codeface`.`cc_list` (`who` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`commit`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`commit` ;

CREATE TABLE IF NOT EXISTS `codeface`.`commit` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `commitHash` VARCHAR(255) NOT NULL,
  `commitDate` DATETIME NOT NULL,
  `authorDate` DATETIME NOT NULL,
  `authorTimeOffset` INT NULL DEFAULT NULL,
  `authorTimezones` VARCHAR(255) NULL DEFAULT NULL,
  `author` BIGINT NOT NULL,
  `projectId` BIGINT NOT NULL,
  `ChangedFiles` INT NULL DEFAULT NULL,
  `AddedLines` INT NULL DEFAULT NULL,
  `DeletedLines` INT NULL DEFAULT NULL,
  `DiffSize` INT NULL DEFAULT NULL,
  `CmtMsgLines` INT NULL DEFAULT NULL,
  `CmtMsgBytes` INT NULL DEFAULT NULL,
  `NumSignedOffs` INT NULL DEFAULT NULL,
  `NumTags` INT NULL DEFAULT NULL,
  `general` INT NULL DEFAULT NULL,
  `TotalSubsys` INT NULL DEFAULT NULL,
  `Subsys` VARCHAR(45) NULL DEFAULT NULL,
  `inRC` INT NULL DEFAULT NULL,
  `AuthorSubsysSimilarity` FLOAT NULL DEFAULT NULL,
  `AuthorTaggersSimilarity` FLOAT NULL DEFAULT NULL,
  `TaggersSubsysSimilarity` FLOAT NULL DEFAULT NULL,
  `releaseRangeId` BIGINT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `commit_person`
    FOREIGN KEY (`author`)
    REFERENCES `codeface`.`person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `commit_project`
    FOREIGN KEY (`projectId`)
    REFERENCES `codeface`.`project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `commit_release_range`
    FOREIGN KEY (`releaseRangeId`)
    REFERENCES `codeface`.`release_range` (`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `commit_person_idx` ON `codeface`.`commit` (`author` ASC);

CREATE INDEX `commit_project_idx` ON `codeface`.`commit` (`projectId` ASC);

CREATE INDEX `commit_release_end_idx` ON `codeface`.`commit` (`releaseRangeId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`commit_communication`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`commit_communication` ;

CREATE TABLE IF NOT EXISTS `codeface`.`commit_communication` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `commitId` BIGINT NOT NULL,
  `who` BIGINT NOT NULL,
  `communicationType` INT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `commitcom_commit`
    FOREIGN KEY (`commitId`)
    REFERENCES `codeface`.`commit` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `commitcom_person`
    FOREIGN KEY (`who`)
    REFERENCES `codeface`.`person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `commtcom_commit_idx` ON `codeface`.`commit_communication` (`commitId` ASC);

CREATE INDEX `commitcom_person_idx` ON `codeface`.`commit_communication` (`who` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`issue_duplicates`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`issue_duplicates` ;

CREATE TABLE IF NOT EXISTS `codeface`.`issue_duplicates` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `originalBugId` BIGINT NOT NULL,
  `duplicateBugId` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `original_issue_duplicate`
    FOREIGN KEY (`originalBugId`)
    REFERENCES `codeface`.`issue` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `duplicate_issue_duplicate`
    FOREIGN KEY (`duplicateBugId`)
    REFERENCES `codeface`.`issue` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `original_issue_duplicate_idx` ON `codeface`.`issue_duplicates` (`originalBugId` ASC);

CREATE INDEX `duplicate_issue_duplicate_idx` ON `codeface`.`issue_duplicates` (`duplicateBugId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`issue_dependencies`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`issue_dependencies` ;

CREATE TABLE IF NOT EXISTS `codeface`.`issue_dependencies` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `originalIssueId` BIGINT NOT NULL,
  `dependentIssueId` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `dependent_original_issue`
    FOREIGN KEY (`originalIssueId`)
    REFERENCES `codeface`.`issue` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `dependent_dependent_issue`
    FOREIGN KEY (`dependentIssueId`)
    REFERENCES `codeface`.`issue` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `dependent_original_issue_idx` ON `codeface`.`issue_dependencies` (`originalIssueId` ASC);

CREATE INDEX `dependent_dependent_issue_idx` ON `codeface`.`issue_dependencies` (`dependentIssueId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`author_commit_stats`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`author_commit_stats` ;

CREATE TABLE IF NOT EXISTS `codeface`.`author_commit_stats` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `authorId` BIGINT NOT NULL,
  `releaseRangeId` BIGINT NOT NULL,
  `added` INT NULL DEFAULT NULL,
  `deleted` INT NULL DEFAULT NULL,
  `total` INT NULL DEFAULT NULL,
  `numcommits` INT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `author_person_key`
    FOREIGN KEY (`authorId`)
    REFERENCES `codeface`.`person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `releaseRangeId_key`
    FOREIGN KEY (`releaseRangeId`)
    REFERENCES `codeface`.`release_range` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `author_person_key_idx` ON `codeface`.`author_commit_stats` (`authorId` ASC);

CREATE INDEX `releaseRangeId_key_idx` ON `codeface`.`author_commit_stats` (`releaseRangeId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`plots`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`plots` ;

CREATE TABLE IF NOT EXISTS `codeface`.`plots` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `projectId` BIGINT NOT NULL,
  `releaseRangeId` BIGINT NULL DEFAULT NULL,
  `labelx` VARCHAR(45) NULL DEFAULT NULL,
  `labely` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `plot_project_ref`
    FOREIGN KEY (`projectId`)
    REFERENCES `codeface`.`project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `plot_releaseRangeId_ref`
    FOREIGN KEY (`releaseRangeId`)
    REFERENCES `codeface`.`release_range` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `plot_project_ref_idx` ON `codeface`.`plots` (`projectId` ASC);

CREATE INDEX `plot_releaseRangeId_ref_idx` ON `codeface`.`plots` (`releaseRangeId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`plot_bin`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`plot_bin` ;

CREATE TABLE IF NOT EXISTS `codeface`.`plot_bin` (
  `plotID` BIGINT NOT NULL,
  `type` VARCHAR(45) NOT NULL,
  `data` LONGBLOB NOT NULL,
  CONSTRAINT `plot_bin_plot_ref`
    FOREIGN KEY (`plotID`)
    REFERENCES `codeface`.`plots` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `plot_bin_plot_ref_idx` ON `codeface`.`plot_bin` (`plotID` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`cluster`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`cluster` ;

CREATE TABLE IF NOT EXISTS `codeface`.`cluster` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `projectId` BIGINT NOT NULL,
  `releaseRangeId` BIGINT NOT NULL,
  `clusterNumber` INT NULL DEFAULT NULL,
  `clusterMethod` VARCHAR(45) NULL DEFAULT NULL,
  `dot` BIGINT NULL DEFAULT NULL,
  `svg` BIGINT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `project_cluster_ref`
    FOREIGN KEY (`projectId`)
    REFERENCES `codeface`.`project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `dot_plot_bin_data`
    FOREIGN KEY (`dot`)
    REFERENCES `codeface`.`plot_bin` (`plotID`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `svg_plot_bin_data_ref`
    FOREIGN KEY (`svg`)
    REFERENCES `codeface`.`plot_bin` (`plotID`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `cluster_releaseRange`
    FOREIGN KEY (`releaseRangeId`)
    REFERENCES `codeface`.`release_range` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `project_cluster_ref_idx` ON `codeface`.`cluster` (`projectId` ASC);

CREATE INDEX `dot_plot_bin_data_idx` ON `codeface`.`cluster` (`dot` ASC);

CREATE INDEX `svg_plot_bin_data_ref_idx` ON `codeface`.`cluster` (`svg` ASC);

CREATE INDEX `cluster_releaseRange_idx` ON `codeface`.`cluster` (`releaseRangeId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`cluster_user_mapping`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`cluster_user_mapping` ;

CREATE TABLE IF NOT EXISTS `codeface`.`cluster_user_mapping` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `personId` BIGINT NOT NULL,
  `clusterId` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `cluster_cluster_user_ref`
    FOREIGN KEY (`clusterId`)
    REFERENCES `codeface`.`cluster` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `person_cluster_user_ref`
    FOREIGN KEY (`personId`)
    REFERENCES `codeface`.`person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `cluster_cluster_user_ref_idx` ON `codeface`.`cluster_user_mapping` (`clusterId` ASC);

CREATE INDEX `person_cluster_user_ref_idx` ON `codeface`.`cluster_user_mapping` (`personId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`issue_history`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`issue_history` ;

CREATE TABLE IF NOT EXISTS `codeface`.`issue_history` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `changeDate` DATETIME NOT NULL,
  `field` VARCHAR(45) NOT NULL,
  `oldValue` VARCHAR(45) NULL DEFAULT NULL,
  `newValue` VARCHAR(45) NULL DEFAULT NULL,
  `who` BIGINT NOT NULL,
  `issueId` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `issue_history_issue_map`
    FOREIGN KEY (`issueId`)
    REFERENCES `codeface`.`issue` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `issue_history_person_map`
    FOREIGN KEY (`who`)
    REFERENCES `codeface`.`person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `issue_history_issue_map_idx` ON `codeface`.`issue_history` (`issueId` ASC);

CREATE INDEX `issue_history_person_map_idx` ON `codeface`.`issue_history` (`who` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`url_info`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`url_info` ;

CREATE TABLE IF NOT EXISTS `codeface`.`url_info` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `projectId` BIGINT NOT NULL,
  `type` VARCHAR(45) NOT NULL,
  `url` TEXT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `url_info_project`
    FOREIGN KEY (`projectId`)
    REFERENCES `codeface`.`project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `url_info_project_idx` ON `codeface`.`url_info` (`projectId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`timeseries`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`timeseries` ;

CREATE TABLE IF NOT EXISTS `codeface`.`timeseries` (
  `plotId` BIGINT NOT NULL,
  `time` DATETIME NOT NULL,
  `value` DOUBLE NOT NULL,
  `value_scaled` DOUBLE NULL DEFAULT NULL,
  CONSTRAINT `plot_time_double_plot_ref`
    FOREIGN KEY (`plotId`)
    REFERENCES `codeface`.`plots` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `plot_time_double_plot_ref_idx` ON `codeface`.`timeseries` (`plotId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`freq_subjects`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`freq_subjects` ;

CREATE TABLE IF NOT EXISTS `codeface`.`freq_subjects` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `projectId` BIGINT NOT NULL,
  `releaseRangeId` BIGINT NOT NULL,
  `mlId` BIGINT NOT NULL,
  `subject` TEXT NOT NULL,
  `count` INT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `freq_subects_project_ref`
    FOREIGN KEY (`projectId`)
    REFERENCES `codeface`.`project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `freq_subjects_release_range_ref`
    FOREIGN KEY (`releaseRangeId`)
    REFERENCES `codeface`.`release_range` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `freq_subjects_mlId_ref`
    FOREIGN KEY (`mlId`)
    REFERENCES `codeface`.`mailing_list` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `freq_subects_project_ref_idx` ON `codeface`.`freq_subjects` (`projectId` ASC);

CREATE INDEX `freq_subjects_release_range_ref_idx` ON `codeface`.`freq_subjects` (`releaseRangeId` ASC);

CREATE INDEX `freq_subjects_mlId_ref_idx` ON `codeface`.`freq_subjects` (`mlId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`thread_density`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`thread_density` ;

CREATE TABLE IF NOT EXISTS `codeface`.`thread_density` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `num` DOUBLE NOT NULL,
  `density` DOUBLE NOT NULL,
  `type` VARCHAR(45) NOT NULL,
  `projectId` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `project_thread_density_ref`
    FOREIGN KEY (`projectId`)
    REFERENCES `codeface`.`project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `project_thread_density_ref_idx` ON `codeface`.`thread_density` (`projectId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`pagerank`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`pagerank` ;

CREATE TABLE IF NOT EXISTS `codeface`.`pagerank` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `releaseRangeId` BIGINT NOT NULL,
  `technique` TINYINT NOT NULL,
  `name` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `pagerank_releaserange`
    FOREIGN KEY (`releaseRangeId`)
    REFERENCES `codeface`.`release_range` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `pagerank_releaserange_idx` ON `codeface`.`pagerank` (`releaseRangeId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`pagerank_matrix`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`pagerank_matrix` ;

CREATE TABLE IF NOT EXISTS `codeface`.`pagerank_matrix` (
  `pageRankId` BIGINT NOT NULL,
  `personId` BIGINT NOT NULL,
  `rankValue` DOUBLE NOT NULL,
  PRIMARY KEY (`pageRankId`, `personId`),
  CONSTRAINT `pagerankMatrix_pagerank`
    FOREIGN KEY (`pageRankId`)
    REFERENCES `codeface`.`pagerank` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `pagerankMatrix_person`
    FOREIGN KEY (`personId`)
    REFERENCES `codeface`.`person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `pagerankMatrix_pagerank_idx` ON `codeface`.`pagerank_matrix` (`pageRankId` ASC);

CREATE INDEX `pagerankMatrix_person_idx` ON `codeface`.`pagerank_matrix` (`personId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`edgelist`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`edgelist` ;

CREATE TABLE IF NOT EXISTS `codeface`.`edgelist` (
  `clusterId` BIGINT NOT NULL,
  `fromId` BIGINT NOT NULL,
  `toId` BIGINT NOT NULL,
  `weight` DOUBLE NOT NULL,
  CONSTRAINT `edgelist_person_from`
    FOREIGN KEY (`fromId`)
    REFERENCES `codeface`.`person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `edgeList_person_to`
    FOREIGN KEY (`toId`)
    REFERENCES `codeface`.`person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `edgeList_cluster`
    FOREIGN KEY (`clusterId`)
    REFERENCES `codeface`.`cluster` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `edgelist_person_from_idx` ON `codeface`.`edgelist` (`fromId` ASC);

CREATE INDEX `edgelist_person_to_idx` ON `codeface`.`edgelist` (`toId` ASC);

CREATE INDEX `edgeList_cluster_idx` ON `codeface`.`edgelist` (`clusterId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`twomode_edgelist`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`twomode_edgelist` ;

CREATE TABLE IF NOT EXISTS `codeface`.`twomode_edgelist` (
  `releaseRangeId` BIGINT NOT NULL,
  `source` CHAR(7) NOT NULL,
  `mlId` BIGINT NOT NULL,
  `fromVert` BIGINT NOT NULL,
  `toVert` VARCHAR(255) NOT NULL,
  `weight` DOUBLE NOT NULL,
  CONSTRAINT `twomode_edgelist_releaseRange`
    FOREIGN KEY (`releaseRangeId`)
    REFERENCES `codeface`.`release_range` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `twomode_edgelist_person`
    FOREIGN KEY (`fromVert`)
    REFERENCES `codeface`.`person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `twomode_edgelist_mlId`
    FOREIGN KEY (`mlId`)
    REFERENCES `codeface`.`mailing_list` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `twomode_edgelist_releaseRange_idx` ON `codeface`.`twomode_edgelist` (`releaseRangeId` ASC);

CREATE INDEX `twomode_edgelist_person_idx` ON `codeface`.`twomode_edgelist` (`fromVert` ASC);

CREATE INDEX `twomode_edgelist_mlId_idx` ON `codeface`.`twomode_edgelist` (`mlId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`twomode_vertices`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`twomode_vertices` ;

CREATE TABLE IF NOT EXISTS `codeface`.`twomode_vertices` (
  `releaseRangeId` BIGINT NOT NULL,
  `source` CHAR(7) NOT NULL,
  `mlId` BIGINT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `degree` DOUBLE NOT NULL,
  `type` SMALLINT NOT NULL,
  CONSTRAINT `twomode_vertices_releaseRange`
    FOREIGN KEY (`releaseRangeId`)
    REFERENCES `codeface`.`release_range` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `twomode_vertices_mlId`
    FOREIGN KEY (`mlId`)
    REFERENCES `codeface`.`mailing_list` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `twomode_vertices_releaseRange_idx` ON `codeface`.`twomode_vertices` (`releaseRangeId` ASC);

CREATE INDEX `twomode_vertices_mlId_idx` ON `codeface`.`twomode_vertices` (`mlId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`initiate_response`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`initiate_response` ;

CREATE TABLE IF NOT EXISTS `codeface`.`initiate_response` (
  `releaseRangeId` BIGINT NOT NULL,
  `mlId` BIGINT NOT NULL,
  `personId` BIGINT NOT NULL,
  `source` TINYINT NOT NULL,
  `responses` INT NULL DEFAULT NULL,
  `initiations` INT NULL DEFAULT NULL,
  `responses_received` INT NULL DEFAULT NULL,
  `deg` DOUBLE NULL DEFAULT NULL,
  CONSTRAINT `initiate_response_releaseRange`
    FOREIGN KEY (`releaseRangeId`)
    REFERENCES `codeface`.`release_range` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `initiate_response_person`
    FOREIGN KEY (`personId`)
    REFERENCES `codeface`.`person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `initiate_response_mlId`
    FOREIGN KEY (`mlId`)
    REFERENCES `codeface`.`mailing_list` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `initiate_response_releaseRange_idx` ON `codeface`.`initiate_response` (`releaseRangeId` ASC);

CREATE INDEX `initiate_response_person_idx` ON `codeface`.`initiate_response` (`personId` ASC);

CREATE INDEX `initiate_response_mlId_idx` ON `codeface`.`initiate_response` (`mlId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`per_cluster_statistics`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`per_cluster_statistics` ;

CREATE TABLE IF NOT EXISTS `codeface`.`per_cluster_statistics` (
  `projectId` BIGINT NOT NULL,
  `releaseRangeId` BIGINT NOT NULL,
  `clusterId` BIGINT NOT NULL,
  `technique` TINYINT NOT NULL,
  `num_members` INT(11) NOT NULL,
  `added` INT(11) NOT NULL,
  `deleted` INT(11) NOT NULL,
  `total` INT(11) NOT NULL,
  `numcommits` INT(11) NOT NULL,
  `prank_avg` DOUBLE NOT NULL,
  CONSTRAINT `per_cluster_statistics_projectId_ref`
    FOREIGN KEY (`projectId`)
    REFERENCES `codeface`.`project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `per_cluster_statistics_rr_ref`
    FOREIGN KEY (`releaseRangeId`)
    REFERENCES `codeface`.`release_range` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `fk_per_cluster_statistics_1_idx` ON `codeface`.`per_cluster_statistics` (`projectId` ASC);

CREATE INDEX `fk_per_cluster_statistics_1_idx1` ON `codeface`.`per_cluster_statistics` (`releaseRangeId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`sloccount_ts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`sloccount_ts` ;

CREATE TABLE IF NOT EXISTS `codeface`.`sloccount_ts` (
  `plotId` BIGINT NOT NULL,
  `time` DATETIME NOT NULL,
  `person_months` DOUBLE NOT NULL,
  `total_cost` DOUBLE NOT NULL,
  `schedule_months` DOUBLE NOT NULL,
  `avg_devel` DOUBLE NOT NULL,
  CONSTRAINT `sloccount_ts_plotid_ref`
    FOREIGN KEY (`plotId`)
    REFERENCES `codeface`.`plots` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `time_UNIQUE` ON `codeface`.`sloccount_ts` (`time` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`understand_raw`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`understand_raw` ;

CREATE TABLE IF NOT EXISTS `codeface`.`understand_raw` (
  `plotId` BIGINT NOT NULL,
  `time` DATETIME NOT NULL,
  `kind` VARCHAR(30) NOT NULL,
  `name` VARCHAR(45) NULL,
  `variable` VARCHAR(45) NOT NULL,
  `value` DOUBLE NOT NULL,
  CONSTRAINT `understand_raw_id_ref`
    FOREIGN KEY (`plotId`)
    REFERENCES `codeface`.`plots` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `understand_raw_kind_idx` ON `codeface`.`understand_raw` (`kind` ASC);

CREATE INDEX `understand_raw_plotId_idx` ON `codeface`.`understand_raw` (`plotId` ASC);


-- -----------------------------------------------------
-- Table `codeface`.`commit_dependency`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `codeface`.`commit_dependency` ;

CREATE TABLE IF NOT EXISTS `codeface`.`commit_dependency` (
  `id` BIGINT NULL AUTO_INCREMENT,
  `commitId` BIGINT NOT NULL,
  `file` VARCHAR(255) NOT NULL,
  `entityId` VARCHAR(255) NOT NULL,
  `entityType` VARCHAR(100) NOT NULL,
  `size` INT NULL,
  `impl` TEXT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_commit_dependency`
    FOREIGN KEY (`commitId`)
    REFERENCES `codeface`.`commit` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `fk_1_idx` ON `codeface`.`commit_dependency` (`commitId` ASC);

USE `codeface` ;

-- -----------------------------------------------------
-- Placeholder table for view `codeface`.`revisions_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `codeface`.`revisions_view` (`projectId` INT, `releaseRangeID` INT, `date_start` INT, `date_end` INT, `date_rc_start` INT, `tag` INT, `cycle` INT);

-- -----------------------------------------------------
-- Placeholder table for view `codeface`.`author_commit_stats_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `codeface`.`author_commit_stats_view` (`Name` INT, `ID` INT, `releaseRangeId` INT, `added` INT, `deleted` INT, `total` INT, `numcommits` INT);

-- -----------------------------------------------------
-- Placeholder table for view `codeface`.`per_person_cluster_statistics_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `codeface`.`per_person_cluster_statistics_view` (`'projectId'` INT, `'releaseRangeId'` INT, `'clusterId'` INT, `'personId'` INT, `'technique'` INT, `'rankValue'` INT, `'added'` INT, `'deleted'` INT, `'total'` INT, `'numcommits'` INT);

-- -----------------------------------------------------
-- Placeholder table for view `codeface`.`cluster_user_pagerank_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `codeface`.`cluster_user_pagerank_view` (`id` INT, `personId` INT, `clusterId` INT, `technique` INT, `rankValue` INT);

-- -----------------------------------------------------
-- Placeholder table for view `codeface`.`per_cluster_statistics_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `codeface`.`per_cluster_statistics_view` (`'projectId'` INT, `'releaseRangeId'` INT, `'clusterId'` INT, `technique` INT, `'num_members'` INT, `'added'` INT, `'deleted'` INT, `'total'` INT, `'numcommits'` INT, `'prank_avg'` INT);

-- -----------------------------------------------------
-- Placeholder table for view `codeface`.`pagerank_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `codeface`.`pagerank_view` (`pageRankId` INT, `authorId` INT, `name` INT, `rankValue` INT);

-- -----------------------------------------------------
-- procedure update_per_cluster_statistics
-- -----------------------------------------------------

USE `codeface`;
DROP procedure IF EXISTS `codeface`.`update_per_cluster_statistics`;

DELIMITER $$
USE `codeface`$$
CREATE PROCEDURE `codeface`.`update_per_cluster_statistics` ()
BEGIN
	TRUNCATE per_cluster_statistics;
	INSERT INTO per_cluster_statistics SELECT * FROM per_cluster_statistics_view;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- View `codeface`.`revisions_view`
-- -----------------------------------------------------
DROP VIEW IF EXISTS `codeface`.`revisions_view` ;
DROP TABLE IF EXISTS `codeface`.`revisions_view`;
USE `codeface`;
CREATE  OR REPLACE VIEW `codeface`.`revisions_view` AS
SELECT 
	p.id as projectId,
	rr.id as releaseRangeID,
	rt_s.date as date_start, 
	rt_e.date as date_end, 
	rt_rs.date as date_rc_start, 
	rt_s.tag as tag, 
	concat(rt_s.tag,'-',rt_e.tag) as cycle
FROM 
	release_range rr JOIN release_timeline rt_s ON rr.releaseStartId = rt_s.id
	JOIN release_timeline rt_e ON rr.releaseEndId = rt_e.id
	LEFT JOIN release_timeline rt_rs ON rr.releaseRCStartId = rt_rs.id
	JOIN project p ON rr.projectId = p.id
order by rr.id asc;

-- -----------------------------------------------------
-- View `codeface`.`author_commit_stats_view`
-- -----------------------------------------------------
DROP VIEW IF EXISTS `codeface`.`author_commit_stats_view` ;
DROP TABLE IF EXISTS `codeface`.`author_commit_stats_view`;
USE `codeface`;
CREATE  OR REPLACE VIEW `codeface`.`author_commit_stats_view` AS
SELECT 
	p.name as Name, 
	s.authorId as ID, 
	s.releaseRangeId, 
	sum(s.added) as added, 
	sum(s.deleted) as deleted, 
	sum(s.total) as total, 
	sum(s.numcommits) as numcommits
FROM author_commit_stats s join person p on p.id = s.authorId
WHERE 
s.authorId IN 
	(	select distinct(authorId) 
		FROM author_commit_stats)
GROUP BY s.authorId, p.name, s.releaseRangeId;

-- -----------------------------------------------------
-- View `codeface`.`per_person_cluster_statistics_view`
-- -----------------------------------------------------
DROP VIEW IF EXISTS `codeface`.`per_person_cluster_statistics_view` ;
DROP TABLE IF EXISTS `codeface`.`per_person_cluster_statistics_view`;
USE `codeface`;
CREATE  OR REPLACE VIEW `codeface`.`per_person_cluster_statistics_view` AS
select 
    rr.projectId as 'projectId',
    rr.id as 'releaseRangeId',
    c.id as 'clusterId',
    p.id as 'personId',
	pr.technique as 'technique',
	prm.rankValue as 'rankValue',
    sum(acs.added) as 'added',
    sum(acs.deleted) as 'deleted',
    sum(acs.total) as 'total',
    sum(acs.numcommits) as 'numcommits'
from release_range rr INNER JOIN (cluster c, cluster_user_mapping cum, person p, author_commit_stats acs, pagerank pr, pagerank_matrix prm)
	ON (rr.id = c.releaseRangeId
		AND c.id = cum.clusterId
        AND cum.personId = p.id
		AND rr.id = acs.releaseRangeId
		AND p.id = acs.authorId
		AND rr.id = pr.releaseRangeID
		AND pr.id = prm.pageRankId
		AND p.id = prm.personId)
group by rr.projectId , rr.id , c.id , p.id, pr.technique, prm.rankValue;

-- -----------------------------------------------------
-- View `codeface`.`cluster_user_pagerank_view`
-- -----------------------------------------------------
DROP VIEW IF EXISTS `codeface`.`cluster_user_pagerank_view` ;
DROP TABLE IF EXISTS `codeface`.`cluster_user_pagerank_view`;
USE `codeface`;
CREATE  OR REPLACE VIEW `codeface`.`cluster_user_pagerank_view` AS
SELECT
	cum.id, 
	cum.personId,
	cum.clusterId AS clusterId,
	pr.technique,
	prm.rankValue
FROM
	cluster_user_mapping cum
	INNER JOIN (cluster c, pagerank_matrix prm, pagerank pr)
	ON (cum.personId = prm.personId AND
	    cum.clusterId = c.id AND
	    prm.pageRankId = pr.id AND
	    c.releaseRangeId = pr.releaseRangeId);

-- -----------------------------------------------------
-- View `codeface`.`per_cluster_statistics_view`
-- -----------------------------------------------------
DROP VIEW IF EXISTS `codeface`.`per_cluster_statistics_view` ;
DROP TABLE IF EXISTS `codeface`.`per_cluster_statistics_view`;
USE `codeface`;
CREATE  OR REPLACE VIEW `codeface`.`per_cluster_statistics_view` AS
select 
    rr.projectId as 'projectId',
    rr.id as 'releaseRangeId',
    c.id as 'clusterId',
	pr.technique,
    count(p.id) as 'num_members',
    sum(acs.added) as 'added',
    sum(acs.deleted) as 'deleted',
    sum(acs.total) as 'total',
    sum(acs.numcommits) as 'numcommits',
	avg(prm.rankValue) as 'prank_avg'
from release_range rr INNER JOIN (cluster c, cluster_user_mapping cum, person p, author_commit_stats acs, pagerank pr, pagerank_matrix prm)
	ON (rr.id = c.releaseRangeId
		AND c.id = cum.clusterId
        AND cum.personId = p.id
		AND rr.id = acs.releaseRangeId
		AND p.id = acs.authorId
		AND rr.id = pr.releaseRangeID
		AND pr.id = prm.pageRankId
		AND p.id = prm.personId)
group by rr.projectId , rr.id , c.id, pr.technique;

-- -----------------------------------------------------
-- View `codeface`.`pagerank_view`
-- -----------------------------------------------------
DROP VIEW IF EXISTS `codeface`.`pagerank_view` ;
DROP TABLE IF EXISTS `codeface`.`pagerank_view`;
USE `codeface`;
CREATE  OR REPLACE VIEW `codeface`.`pagerank_view` AS
SELECT
	prm.pageRankId as pageRankId,
	p.id as authorId,
	p.name AS name,
        prm.rankValue AS rankValue
FROM pagerank_matrix prm JOIN person p ON p.id=prm.personId;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
