# easy_schrodinger_scripts

A collection of scripts designed to simplify and automate various tasks for Schrödinger molecular modelling software. These scripts aim to enhance productivity and streamline user workflows on high-performance computing (HPC) systems, such as the Lengau CHPC cluster.

---

### **easy_desmond_report**

This script automates the generation of Desmond molecular dynamics simulation (MDS) reports (e.g., RMSD, RMSF plots, and related data) directly on the South African Lengau CHPC cluster. Many users interested in generating these reports often download large trajectory folders (`*_trj`) and output CMS files (`*-out.cms`) to their local machines to generate reports with the Simulation Interaction Diagram. However, this process can be data-intensive for sizable systems and long simulations.

With `easy_desmond_report`, the entire process happens on the cluster, reducing data transfer requirements. The reports are saved in a compact directory, ready for seamless download.

#### **Features:**

- Optimized for the Lengau CHPC cluster.
- Automates report generation.
- Saves time and minimizes data usage.

#### **Resources:**

- <a href="https://www.youtube.com/" target="_blank">Brief Tutorial Video</a>

---

Additional sections will be added as more scripts are included in the repository. Each section will describe the purpose, features, and usage of the respective script.
