## [1.1.7] - 2025-12-16
### ✨ Features
- Add `init` command for interactive project setup, refactor `icons` command to expose static generation, and implement iOS splash screen updates.
- Introduce new commands for versioning, project health, icon and splash screen generation, changelog management, and gitignore.

### 🔧 Improvements
- Update README with new `publish` commands and improved section organization.
- Fixed argument definition from `required` to `mandatory` and remove unused variable and comment.
- Remove duplicate changelog entries for version 1.1.6

## [1.1.6] - 2025-12-16
No user-facing changes.

## [1.1.5]
 - Added support for multiple build.gradle file formats (Groovy and Kotlin DSL).
 - Enhanced gradle parser to handle various applicationId syntax patterns.
 - Added comprehensive gradle format examples in supported_gradle_formats folder.

## [1.1.4]
 - Update a dependency to the latest release. 

## [1.1.3]
 - Fixed bug in build.gradle default block. 
 - Enhanced error messages for invalid input.

## [1.0.9]
Update README for cleanup instructions, and enhance 

## [1.0.8]
Enhance applicationId regex to support both old and new formats in build file

## [1.0.6]
Added functionality to change package name during signing setup

## [1.0.4]
Fixed validity years input bug.

## [1.0.2]
Improved key generation process with user prompts for Common Name, Organizational Unit,
Organization, Locality, State, Country, and Validity inputs. Defaults provided for easy use.

## [1.0.0]
Added support for generating core and feature directories via the gen command.

## [0.0.1]
Initial release of the publish package, featuring Android signing key generation and signed bundle
creation.
