locals {

  dbfs_list = [
    "dbfs:/FileStore/jars/0fe574af_7b84_4a9a_8f6c_8b8f8b1c8c45/ldap3-2.9.1-py2.py3-none-any.whl",
    "dbfs:/FileStore/jars/02dee58f_1c90_4af0_b20d_b1f027404b32/azure_appconfiguration-1.3.0-py2.py3-none-any.whl",
    "dbfs:/FileStore/jars/2fbabb49_6507_40c4_aa2c_3dee03d8f25b/office365-0.3.15-py3-none-any.whl",
    "dbfs:/FileStore/jars/9d56e828_69a7_4474_88ab_1294592bf159/flask-3.0.0-py3-none-any.whl",
    "dbfs:/FileStore/jars/36a5b5d4_59a3_498e_9858_2600a71e23b4/azure_identity-1.11.0-py3-none-any.whl",
    "dbfs:/FileStore/jars/540bd610_699c_423f_9bb4_8f84c5c9b701/networkx-2.8.8-py3-none-any.whl",
    "dbfs:/FileStore/jars/781be5db_66a5_430b_bcc8_2ce77e8fd408/azure_storage_blob-12.14.1-py3-none-any.whl",
    "dbfs:/FileStore/jars/4729bbeb_bc05_44f8_ab12_23cf980f6a40/azure_keyvault_secrets-4.3.0-py2.py3-none-any.whl",
    "dbfs:/FileStore/jars/c6dc305f_7e9a_4275_88da_262e905a6481/SharePlum-0.5.1-py2.py3-none-any.whl",
    "dbfs:/FileStore/jars/dcdf79af_76fc_4e77_b04c_7c4600a1a075/simple_salesforce-1.11.4-py2.py3-none-any.whl",
    "dbfs:/FileStore/jars/dfe525b9_5aa2_4345_90ef_501852c33c48/msal-1.23.0-py2.py3-none-any.whl"
    ]

    existing_to_new_ip_ids = {
      "0626-135020-scows221-pool-wdavca0i"="0224-232044-prong2-pool-nban7gyv"
      "0626-134951-gamer220-pool-zdzw96eq"="0224-232044-denim33-pool-7udvev8n"
      "0626-134859-levy267-pool-r7jd51o2"="0224-232044-plugs52-pool-ocg25bqf"
      "0909-170232-glass291-pool-1ob1xgvm"="0224-232044-chins1-pool-4ucb7fdz"
      "0910-093158-mud345-pool-1xt5071u"="0224-232044-cargo18-pool-atrmic9z"
      "0909-170235-tub346-pool-lzqc0436"="0224-232044-ibex50-pool-m581j3c7"
      "0909-170237-rusts275-pool-471ps2ia"="0224-232044-bash2-pool-nhc87grr"
      "0910-093200-pilau270-pool-3co0zvzm"="0224-232044-duh51-pool-jbex497r"
      "0910-093202-gents346-pool-fulrz5bm"="0224-232044-plot17-pool-6v33yopz"
    }


  flattened_notebook_paths = flatten([
    for i, notebook_paths in data.databricks_notebook_paths.existing_notebook_paths : [
      for notebook_path in notebook_paths.notebook_path_list : {
        path        = notebook_path.path
        language    = notebook_path.language
        directories = replace(dirname(notebook_path.path), "\\", "/")
      }
    ]
  ])

  flattened_library_paths = flatten([
    for library_path in data.databricks_dbfs_file_paths.existing_dbfs_file_paths.path_list : {
      path      = library_path.path
      file_size = library_path.file_size
    }
  ])

  unique_directory_paths = distinct([
    for path in local.flattened_notebook_paths : path.directories
  ])

  cluster_library_combinations = flatten([
    for cluster_id in databricks_cluster.new_cluster[*].id : [
      for library_path in local.flattened_library_paths : {
        cluster_id   = cluster_id
        library_path = join("", ["dbfs:", library_path.path])
      }
    ]
  ])
}