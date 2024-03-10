select * from (
                  select '2023-03-10'                                     as date,
                         'balance'                                        as description,
                         '-' as reference,
                         sum(gl_entries.cr_amount - gl_entries.dr_amount) as receipt,
                         0                                                as payment

                  from cash_books
                           join gl_entry_groups
                                on cash_books.gl_entry_group_id = gl_entry_groups.id
                           join gl_entries on gl_entry_groups.id = gl_entries.gl_entry_group_id
                           join gl_accounts on gl_accounts.code = gl_entries.account
                  where gl_accounts.gl_account_type = 'DEPOSIT'
                    and cash_books.date < '2023-03-10'
                    and cash_books.facility_id = 19739


                  UNION ALL


                  select cash_books.date,
                         cash_books.description,
                         cash_books.reference_no as reference,
                          gl_entries.cr_amount as receipt,
                          gl_entries.dr_amount  as payment
                  from cash_books
                           join gl_entry_groups
                                on cash_books.gl_entry_group_id = gl_entry_groups.id
                           join gl_entries on gl_entry_groups.id = gl_entries.gl_entry_group_id
                           join gl_accounts on gl_accounts.code = gl_entries.account
                  where gl_accounts.gl_account_type = 'DEPOSIT'
                    and cash_books.facility_id = 19739
    and cash_books.date >= '2023-03-10' and cash_books.date <=  '2023-03-18'
              )sub  order by date
