# ASC_CO2
Simulation of amplitude of seasonal cycle (ASC) of CO~2~ using P model.

## Scheme and procedure

The simulation of CO~2~ ASC spans from 1901 to 2016 on a global scale (0.5*0.5 degree), assuming vegetation carbon pool and soil carbon pool is in equilibrium in 1901, and calculate changes in these pools and consequently the ecosystem respiration due to environmental changes, and finally the amplitude of CO~2~ ASC using atmospheric transport modelling (TM3).

In this simulation, gross primary production (GPP) is first quanified using [Pyrealm package](https://github.com/davidorme/pyrealm/tree/master)  based on P model. Using biomass production efficiency (BFE), GPP is partitioned into autotrophic respiration (Ra) and net primary production (NPP), which contributes to vegetation biomass carbon. Using vegetation turnover rate, vegetation biomass carbon is converted to soil carbon , and then heterotrophic respiration can be calculated from labile soil carbon, a fraction of soil carbon that is accessible to decomposition.

A flowchart of the simulation is provided below. The detailed procedure and data inputs used in the simulation is in later section.

 ```mermaid
 graph LR
 A(gross primary production) -- biomass production efficiency --> B[autotrophic respiration]
 A(gross primary production) -- biomass production efficiency --> C[Net primary production]
 C[net primary production] --> D[vegetation biomass carbon] -- vegetation turnover --> F[soil carbon] --> E[ heterotrophic respiration]
 ```

Specifically in each year, vegetation biomass carbon ($$C_{veg}$$) and soil carbon ($$C_{soil}$$) are calculated recursively as:
$$
C_{veg}(i) = C_{veg}(i-1)+NPP(i)-C_{veg}(i) \times k_{veg}
$$

$$
C_{soil}(i) = C_{soil}(i-1)+C_{veg}(i) \times k_{veg}-C_{labC}(i)\times k_{s}
$$

Assuming at steady state in 1901 and an invariant vegetation turnover rate $$k_{veg}$$ is calculated:
$$
k_{veg}=\frac{NPP(1901)}{Cveg(1901)}
$$
Labile soil carbon ($$C_{labC}$$) is calculated as $$C_{labC} = \alpha C_{soil}$$, $$\alpha$$ is the function of environmental variables (TBC).

### Biomass production efficiency (BFE)

Net primary production (NPP) are calculated using biomass production efficiency, the ratio of NPP/GPP: NPP = GPP × $$\sum$$BFE; then autotrophic respiration (Ra) can be calcualted as Ra = GPP - NPP. 

BFE is a constant value for each plant functional types (PFT) except for forest. For forest, BFE = 0.19+0.006×MAT-0.00038×age+6.8E-5×TAP +0.0039×|lat|. MAT stands for mean annual temperature, while TAP stands for total annual precipitation. The BFE value for other PFT are derived from He et al. (2020)[^1] and Campioli et al. (2015)[^2], and is shown in the table

 

| Plant functional type (PFT) | Biomass production efficiency (BFE) |
| --------------------------- | ----------------------------------- |
| Grassland                   | 0.45                                |
| Cropland                    | 0.55                                |
| Tundra                      | 0.45                                |
| Savanna                     | 0.47                                |
| Shrubland                   | 0.47                                |

### Soil heterotrophic respiration rate

Soil heterotrophic respiration rate is calculated as $$k_s = f(T) \times f(M)$$, while f(T) and f(M) is soil heterotrophic respiration affected by temperature and soil moisture respectively. 

The temperature function of soil heterotrophic respiration uses the $$Q_{10}$$, but instead of a simple $$Q_{10}$$ with single air temperature, we used a depth-resolved f(T) averaging f(T) at every 10cm over the full 0-1 m depth interval following Kovern et al. 2017[^3], to account for the vertical variation in soil climate. Temperature at each depth is calculated following Campbell and Norman (1998)[^4] as follows:
$$
T_{z,t} = T_{mean}+A_0exp(-z/d)sin(\omega t-z/d)
$$
where $$T_{mean}$$ is the annual mean air temperature, $$A_0$$ isthe annual temperature amplitude (half of the difference between the coldest and warmest month air temperature), $$\omega=2 \pi / \tau$$ with $$\tau$$=12 months. d is damping depth given by d=2k/$$\omega$$ where k is the abundance-weighted thermal diffusivity of soil components. Here k (m^2^ month^-1^ ) is fixed for each soil texture type: k for soil organic matter, clay, silt and sand is 0.368, 0.815, 0.946 and 1.76 respectively.

Based on reference f(T) at 15 degree celsius, the monthly f(T) is calculated using
$$
f(T) = \sum_0^{z}f(15)Q_{10}^{(T_{z}-15)/10}
$$
Where $$Q_{10}$$ is fixed at 1.5. 

The moisture function of soil respiration rate followed Yan et al. (2018)[^5] as follows:
$$
f(M) = \left\{
\begin{array}{lcl}
\frac{K_\theta+\theta_{op}}{K_\theta+\theta}(\frac{\theta}{\theta_{op}})^{1+an_s},  &   & {\theta<\theta_{op}}\\
(\frac{\phi-\theta}{\phi-\theta_{op}})^b,     &      & {\theta \geq \theta_{op}}\\
\end{array} \right.
$$
Where $$\theta$$ is soil moisture (m^3^ m^-3^), $$\theta_{op}$$ is optimum water content given by soil porosity $$\phi$$ as $$\theta_{op}=0.65 \phi$$. $$K_{\theta}$$ is the moisture constant; $$n_s$$ is saturation exponent dependent on soil structure and texture; b is the O~2~ supply restriction factor. Here the value for $$K_{\theta}, n_s$$ and b is fixed at 0.1, 2 and 0.75 respectively.

Monthly soil respiration is calculated as above and aggregated to obtain annual soil respiration.

## Forcing data

GPP is forced by meterological data from CRU4.04, which covers monthly mean air temperature, minimum and maximum temperature and vapour pressure. Solar radiation are derived from [WFD](https://catalogue.ceh.ac.uk/documents/31dd5dd3-85b7-45f3-96a3-6e6023b0ad61) (1901-1978) combined with [WFDE5](https://cds.climate.copernicus.eu/cdsapp#!/dataset/10.24381/cds.20d54e34?tab=overview) (1979-2016) with WFD corrected to match with WFDE5. fAPAR data were downloaded from [GIMMS 3g fAPAR](https://drive.google.com/drive/folders/0BwL88nwumpqYaFJmR2poS0d1ZDQ); as remote sensing data of vegetation cover is not avilable before 1982, fAPAR in 1982 was used for period 1901-1981.

Meterological data derived from CRU4.01 was used in SPLASH v2.0, including precipitation, temperature and cloud cover, which then coverted to solar radiation.

Forest age map used to quantify forest biomass production efficiency is downloaded at [GFAD v1.1](https://doi.pangaea.de/10.1594/PANGAEA.897392), and land cover used to calculate NPP and Ra are derived from [ISAM-HYDE](https://www.atmos.illinois.edu/~meiyapp2/datasets.htm) (1901-2010) and MODIS land cover product [MCD12C1 v006](https://lpdaac.usgs.gov/products/mcd12c1v006/) (2011-2016). For consistency, initial global carbon pool data of vegetation and soil were also derived from ISAM model in TRENDY v8.

Soil property data, including fraction of soil texture type, porosity, and fraction of organic matter were derived from [ISRIC-WISE global dataset (v3.0)](https://data.isric.org/geonetwork/srv/eng/catalog.search#/metadata/d9eca770-29a4-4d95-bf93-f32e1ab419c3) to quantify soil respiration rate.

## Reference

[^1]:He, Y, Peng, S, Liu, Y, et al. Global vegetation biomass production efficiency constrained by models and observations. *Glob Change Biol*.; 26: 1474– 1484 (2020). https://doi.org/10.1111/gcb.14816
[^2]:Campioli, M., Vicca, S., Luyssaert, S. *et al.* Biomass production efficiency controlled by management in temperate and boreal ecosystems. *Nature Geosci* **8,** 843–846 (2015). https://doi.org/10.1038/ngeo2553
[^3]: Koven, C., Hugelius, G., Lawrence, D. *et al.* Higher climatological temperature sensitivity of soil carbon in cold than warm climates. *Nature Clim Change* **7,** 817–822 (2017). https://doi.org/10.1038/nclimate3421
[^4]: Campbell, G. S., & Norman, J.  *An introduction to environmental biophysics*. Springer Science & Business Media. (2012). 
[^5]: Yan, Z., Bond-Lamberty, B., Todd-Brown, K.E. *et al.* A moisture function of soil heterotrophic respiration that incorporates microscale processes. *Nat Commun* **9,** 2562 (2018). https://doi.org/10.1038/s41467-018-04971-6

