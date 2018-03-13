# 后端用户表
class User < ActiveRecord::Base
  self.table_name = 'frameworkuser'
  has_many :framework_user_roles, foreign_key: 'FrameworkUserBase_ID'
  has_many :framework_roles, through: 'framework_user_roles', foreign_key: 'FrameworkUserBase_ID'
  has_many :data_privileges,foreign_key: 'UserID'



  # 判断用户是否有采购单及采购价的一级,或者二级，三级的审批权限
  # functionprivileges表Allowed = 0表示拒绝此权限,allowed=1表示允许此权限；后台子节点设置为无，则如果父节点设置为允许，则子节点也有权限
  def self.approval_permissions user_id,parent_url,menu_url
    @user = User.find(user_id)
    role_ids = @user.framework_roles.pluck(:ID)
    @menu = FrameworkMenu.where(Url:menu_url).first

    @menu2 = @menu
    menu_ids = [].push(@menu.id)
    flag = true
    while flag
      @menu2 = @menu2.parent_menu
      if @menu2
        menu_ids.push(@menu2.ID)
      else
        flag = false
      end
    end


    # 顶级父节点权限
    functions_privilieages_first = FunctionPrivileage.where(RoleID:role_ids,MenuItemId: menu_ids.last,Allowed:1) #如果没有记录，并且子节点都为无则说明没有所有的权限，如果子节点为允许，则有权限
    functions_privilieages = FunctionPrivileage.where(RoleID:role_ids,MenuItemId: menu_ids,Allowed:0) #没有记录则说明有某个菜单menu的权限； Allowed = 0表示拒绝权限
    functions_privilieages_allowed = FunctionPrivileage.where(RoleID:role_ids,MenuItemId: menu_ids,Allowed:1)

    #如果顶级节点没有记录（后台设置为无），如果子节点没有被拒绝的，且有允许的，则有权限
    if functions_privilieages_first.empty? && functions_privilieages.empty? && !functions_privilieages_allowed.empty?
      return {status:'ok',is_allowed:true,message:'有权限'}
    end

    #如果顶级节点有记录（后台设置允许），并且子节点没有被拒绝的，则有权限
    if functions_privilieages.empty? && !functions_privilieages_first.empty?
      #allowed=0的记录为空，则表示有权限
      return {status:'ok',is_allowed:true,message:'有权限'}
    else
      return {status:'error',is_allowed:false,message:'子节点没有权限'}
    end

  end
=begin
  def self.approval_permissions user_id,parent_url,child_url

    # 父节点权限判断
    sql_optins = "select * from frameworkmenus as menu
              inner join functionprivileges as fun on fun.MenuItemId = menu.ID
              inner join frameworkroles as role on role.ID = fun.RoleID
              inner join frameworkuserrole as userrole on userrole.FrameworkRole_ID = role.ID
              inner join frameworkuser as user on user.ID = userrole.FrameworkUserBase_ID"
    if parent_url == ''
      parent_id = FrameworkMenu.where(Url: child_url).first.ParentID
      where_options = "  where  user.ID = '#{user_id}' AND menu.id = '#{parent_id}'  and fun.Allowed = 1"
    else
      where_options = "  where  user.ID = '#{user_id}' AND menu.Url =  '#{parent_url}'  and fun.Allowed = 1"
    end
    sql = sql_optins << where_options
    parent_reponse = FrameworkMenu.find_by_sql(sql)

    p parent_reponse

    if parent_reponse.empty?
      p 9999
      # 父节点没有权限，则所有子节点都没有权限
      return {status:'error',is_allowed:false,message:'父节点没有权限'}
    else
      p 4444
      # 子节点权限判断
      child_reponse = FrameworkMenu.find_by_sql("select * from frameworkmenus as menu
              inner join functionprivileges as fun on fun.MenuItemId = menu.ID
              inner join frameworkroles as role on role.ID = fun.RoleID
              inner join frameworkuserrole as userrole on userrole.FrameworkRole_ID = role.ID
              inner join frameworkuser as user on user.ID = userrole.FrameworkUserBase_ID
              where  user.ID = '#{user_id}' AND menu.Url =  '#{child_url}'  and fun.Allowed = 0")
      if child_reponse.empty?
        #allowed=0的记录为空，则表示有权限
        return {status:'ok',is_allowed:true,message:'有权限'}
      else
        return {status:'error',is_allowed:false,message:'子节点没有权限'}
      end
    end




  end
=end


  private



  # 返回一个随机令牌
  def self.new_remember_token
    SecureRandom.urlsafe_base64
  end

  # 返回指定字符串的摘要
  def self.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end


end
