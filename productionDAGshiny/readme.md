## Development 

### Design of the App

This app uses modules and models that interact with the backend (reactive data frame) to allow users to add and edit nodes resulting in a DAG.

In the setup, there is a modal to set the treatment and response then the backend toDataStorage data frame is stored and triggers the servers of the other modules. 

### Data Organization 

The app stores the core of its data in a name-to format making it easy to transition to DAG tools. 


#### Data Dictionary

&nbsp;&nbsp;&nbsp;&nbsp; **Name** (string) - Name of the node.

&nbsp;&nbsp;&nbsp;&nbsp; **To** (string) - Name of the child node. Each Name-To pair is unique. 

&nbsp;&nbsp;&nbsp;&nbsp; **base** (bool) - Stores whether the node (based on the Name column) is one of the base nodes. Used for coloring the DAG.

&nbsp;&nbsp;&nbsp;&nbsp; **unmeasured** (bool) - Is the node unmeasured? The default is FALSE.

&nbsp;&nbsp;&nbsp;&nbsp; **conditioned** (bool) - Is the node conditioned on? The default is FALSE.

Example:
| name     | to         | base | unmeasured | conditioned |
|----------|------------|------|------------|-------------|
| treatment| response   | TRUE | FALSE      | FALSE       |
| x1       | response   | FALSE| FALSE      | TRUE        |
| x1       | treatment  | FALSE| FALSE      | TRUE        |
| x2       | x1         | FALSE| FALSE      | FALSE       |
| response | NA         | TRUE | FALSE      | FALSE       |

### Updating Colors

To update the node colors you will need to update the styles.css file as well as the helpers.R file. The helpers.R colors are located at the top of the file. In the css you will need to go to the code labeled /* Node Button Options */ and manually update to match the helpers.R file. 


### Packages

DiagrammeR
- [DiagrammeR](https://rich-iannone.github.io/DiagrammeR/)

DAGitty
- [dagitty](https://www.dagitty.net/)

shinytest2
- [shinytest2](https://rstudio.github.io/shinytest2/)

shinydashboard
 - [shinydashboard](https://rstudio.github.io/shinydashboard/index.html)


