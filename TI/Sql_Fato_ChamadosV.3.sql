select 
  T1.id 'id_ticket', T1.name 'Titulo', T1.date 'Data Abertura', T1.closedate 'Data Fechamento', 
  T1.solvedate 'Data Sol.', T1.date_mod 'Data Ult. Alt.', T1.time_to_resolve 'Data Prev.',
  case 
    when T1.solvedate is null and date_add(T1.time_to_resolve, INTERVAL 1 day) < now() then 'Sim'
    when T1.solvedate > date_add(T1.time_to_resolve, INTERVAL 1 day)  then 'Sim'
    else 'Não'
  end 'Atraso',
  case 
    when T1.status = 1 then 'Novo' 
    when T1.status = 2 then 'Processando - Atribuido'
    when T1.status = 3 then 'Processando - Planejado'
    when T1.status = 4 then 'Pendente'
    when T1.status = 5 then 'Solucionado'
    when T1.status = 6 then 'Fechado'
  end 'Status Chamado',
  T1.users_id_lastupdater, T4.realname 'Usuario Ult. Alt.',  
  T1.content 'Detalhamento Chamado', T1.urgency 'Urgencia', T1.impact 'Impacto', T1.priority 'Prioriade', 
  T1.itilcategories_id, T8.completename 'Categoria', 
  case 
    when T1.type = 1 then 'Incidente' 
    when T1.type = 2 then 'Requisicao'
  end 'Tipo Chamado',
  case  
     when T9.user_name is null then 'Sim'
     else 'Não'
  end 'Solucao Aprovada',
  case  
    when T12.projects_id > 0 then 'Sim'
	else 'Não'
  end 'Projeto', 
  T11.name 'Origem',
  replace(replace(replace(replace(replace(T10.content,'&lt;p&gt;',' ' ),'&lt;/p&gt;',' '),'=&gt;',' '),':&lt;',' '),'em&gt;',' ')  'Solucao', 
  T2.users_id 'users_id_request', T5.realname 'Usuario Abertura', 
  T3.users_id 'users_id_ti', T6.realname 'Tecnico Resp.',
  ifnull(T7.satisfaction,5) 'Nota',  ifnull(T7.comment,'') 'Avaliacao',
  ifnull((select sum(ifnull(T20.actiontime,0) / 3600) from glpi_tickettasks T20 
          where T20.tickets_id  = T1.id ),0) 'Qtde Horas'
from glpi_tickets T1
left join glpi_tickets_users T2 on T1.id = T2.tickets_id and T2.type = 1
inner join glpi_tickets_users T3 on T1.id = T3.tickets_id and T3.type = 2
left join glpi_users T4 on T1.users_id_lastupdater = T4.id
left join glpi_users T5 on T2.users_id = T5.id
left join glpi_users T6 on T3.users_id = T6.id
left join glpi_ticketsatisfactions T7 on T1.id = T7.tickets_id
inner join glpi_itilcategories T8 on T1.itilcategories_id = T8.id
left join glpi_logs T9 on T9.items_id = T1.id 
  and T9.itemtype='Ticket' and T9.id_search_option=17 
  and T9.old_value <> ''
left join glpi_itilsolutions T10 on T10.itemtype = 'Ticket'
  and T10.items_id = T1.id
left join glpi_requesttypes T11 on T11.id = T1.requesttypes_id 
left join glpi_itils_projects T12 on T12.items_id = T1.id
  and T12.itemtype  = 'Ticket'
where T1.is_deleted <> 1