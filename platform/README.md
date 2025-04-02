# Platform

Follow these steps to install the artifacts hub Helm chart package:

**Add the Helm Repository:**  

  ```sh
  helm repo add wenex https://wenex-org.github.io/charts
  helm repo update
  ```

**Install the Chart:**  

  ```sh
  helm install platform wenex/platform
  ```
