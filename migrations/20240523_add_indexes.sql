-- migrate:up
create index recipes_category_btree_idx on kitchen_api_data.recipes using btree(category);

create extension pg_trgm;
create index recipes_title_trgm_idx on kitchen_api_data.recipes using gist(title gist_trgm_ops);

-- migrate:down