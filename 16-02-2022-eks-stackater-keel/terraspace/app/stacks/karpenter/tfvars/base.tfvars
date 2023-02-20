cluster_name = <%= output('eks.cluster_name') %>
cluster_endpoint = <%= output('eks.cluster_endpoint') %>
cluster_certificate_authority_data = <%= output('eks.cluster_certificate_authority_data') %>
oidc_provider_arn = <%= output('eks.oidc_provider_arn') %>
managed_node_group_role_arn = <%= output('eks.managed_node_group_role_arn') %>