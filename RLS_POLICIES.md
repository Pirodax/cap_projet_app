[
  {
    "schema": "public",
    "table_name": "assurance_maladie_regimes",
    "policy_name": "Allow public read access to regime_assurance_maladies",
    "command": "SELECT",
    "using_expression": "true",
    "with_check_expression": null,
    "table_owner": "postgres"
  },
  {
    "schema": "public",
    "table_name": "assurance_maladie_remboursements",
    "policy_name": "Lecture publique remboursements secu",
    "command": "SELECT",
    "using_expression": "true",
    "with_check_expression": null,
    "table_owner": "postgres"
  },
  {
    "schema": "public",
    "table_name": "categories_soins",
    "policy_name": "Les visiteurs peuvent lire les catégories de soins",
    "command": "SELECT",
    "using_expression": "true",
    "with_check_expression": null,
    "table_owner": "postgres"
  },
  {
    "schema": "public",
    "table_name": "mutuelle_formules",
    "policy_name": "Allow public read access to mituelle_formules",
    "command": "SELECT",
    "using_expression": "true",
    "with_check_expression": null,
    "table_owner": "postgres"
  },
  {
    "schema": "public",
    "table_name": "mutuelle_remboursements",
    "policy_name": "Lecture publique remboursements mutuelle",
    "command": "SELECT",
    "using_expression": "true",
    "with_check_expression": null,
    "table_owner": "postgres"
  },
  {
    "schema": "public",
    "table_name": "mutuelle_remboursements",
    "policy_name": "Les visiteurs peuvent lire les détails de remboursement des mu",
    "command": "SELECT",
    "using_expression": "true",
    "with_check_expression": null,
    "table_owner": "postgres"
  },
  {
    "schema": "public",
    "table_name": "mutuelles",
    "policy_name": "Allow public read access to mituelles",
    "command": "SELECT",
    "using_expression": "true",
    "with_check_expression": null,
    "table_owner": "postgres"
  },
  {
    "schema": "public",
    "table_name": "simulation_history",
    "policy_name": "Users can delete own simulations",
    "command": "DELETE",
    "using_expression": "(auth.uid() = user_id)",
    "with_check_expression": null,
    "table_owner": "postgres"
  },
  {
    "schema": "public",
    "table_name": "simulation_history",
    "policy_name": "Users can insert own simulations",
    "command": "INSERT",
    "using_expression": null,
    "with_check_expression": "(auth.uid() = user_id)",
    "table_owner": "postgres"
  },
  {
    "schema": "public",
    "table_name": "simulation_history",
    "policy_name": "Users can update own simulations",
    "command": "UPDATE",
    "using_expression": "(auth.uid() = user_id)",
    "with_check_expression": null,
    "table_owner": "postgres"
  },
  {
    "schema": "public",
    "table_name": "simulation_history",
    "policy_name": "Users can view own simulations",
    "command": "SELECT",
    "using_expression": "(auth.uid() = user_id)",
    "with_check_expression": null,
    "table_owner": "postgres"
  },
  {
    "schema": "public",
    "table_name": "soins",
    "policy_name": "Les visiteurs peuvent lire les détails des soins",
    "command": "SELECT",
    "using_expression": "true",
    "with_check_expression": null,
    "table_owner": "postgres"
  },
  {
    "schema": "public",
    "table_name": "user_infos",
    "policy_name": "Allow user to insert own profile",
    "command": "INSERT",
    "using_expression": null,
    "with_check_expression": "(auth.uid() = user_id)",
    "table_owner": "postgres"
  },
  {
    "schema": "public",
    "table_name": "user_infos",
    "policy_name": "Allow user to update own profile",
    "command": "UPDATE",
    "using_expression": "(auth.uid() = user_id)",
    "with_check_expression": null,
    "table_owner": "postgres"
  },
  {
    "schema": "public",
    "table_name": "user_infos",
    "policy_name": "Allow user to view own profile",
    "command": "SELECT",
    "using_expression": "(auth.uid() = user_id)",
    "with_check_expression": null,
    "table_owner": "postgres"
  }
]