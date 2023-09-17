I suggest using a numbering system to manage project files. For example, the file structure of the `2022_network_analysis` project would be as follows:

```bash
2022_network_analysis
  \-01_code
  	\-a01_analysis.ipynb
  	\-a02_visualize.ipynb
  	\-d11_basic_data.ipynb
  \-02_rdata
    \-raw_data.csv
  \-03_wdata
  	\-0100_reg.csv
  	\-0200_visual.csv
  	\-1100_data_wip.csv
  	\-1101_data_processed.csv
  \-04_result
  	\-tab_baseline.rtf
  	\-fig_trend.svg
```

## Code

The code is stored in `01_code`.

- `a01` represents the first code used for analysis (taking the first letter of "analysis").
- `d11` represents the processing (taking the first letter of "data") of the `11` series of data.

## Raw Data

The raw data is stored in `02_rdata`, which includes externally obtained raw data such as `raw_data.csv`.

Try to avoid changing the original names of the raw data (unless they are files with unclear names exported from platforms like WRDS or CSMAR) to facilitate locating the source of each piece of raw data in the future.

## Processed Data

The processed data is stored in `03_wdata`.

- The components of the data can be written with the prefix `11` or `12`.
	* They can be classified by data source, such as using the `11` prefix for Compustat data and the `12` prefix for CRSP data.
	* They can also be classified by topic, such as using the `11` prefix for stock price data and the `12` prefix for macroeconomic data.
- Data used for analysis starts with `01-09`, such as `01` for regression analysis data and `02` for visualization data.
- The last two digits can be sequentially numbered from `00` to `99`.

??? question "What are the benefits of this numbering system?"

	- The prefix number allows for quick identification of which code processed a particular piece of data.
	- The suffix number indicates the order of data processing in the project workflow.

## Results

The output results are stored in `04_result`.

- The prefix `tab` is used for tables.
- The prefix `fig` is used for images.

??? question "What are the benefits of this numbering system?"

	It facilitates referencing in LaTeX.