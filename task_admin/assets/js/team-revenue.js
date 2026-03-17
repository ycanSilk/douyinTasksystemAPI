/**
 * 团队收益统计相关脚本
 * 负责生成UI布局并调用接口获取数据
 */

/**
 * 加载团队收益概览页面
 * 生成UI布局并加载数据
 */
function loadTeamRevenue() {
  const section = document.getElementById('team-revenueSection');
  const contentDiv = document.getElementById('team-revenue-content');
  
  if (!section || !contentDiv) {
    console.error('团队收益统计区域不存在');
    return;
  }
  
  // 生成UI布局
  contentDiv.innerHTML = generateTeamRevenueUI();
  
  // 初始化页面
  initTeamRevenuePage();
}

/**
 * 生成团队收益统计页面的UI布局
 * @returns {string} HTML字符串
 */
function generateTeamRevenueUI() {
  return `
    <div class="bg-white rounded-xl shadow-md border border-gray-200 overflow-hidden">
      <!-- 查询表单 -->
      <div class="p-6 border-b border-gray-200">
        <form id="searchForm" class="grid grid-cols-8 md:grid-cols-4 lg:grid-cols-8 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">用户ID</label>
            <input type="number" id="userId" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent" placeholder="请输入用户ID">
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">用户名</label>
            <input type="text" id="username" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent" placeholder="请输入用户名">
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">代理等级</label>
            <select id="isAgent" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent">
              <option value="">全部</option>
              <option value="0">普通用户</option>
              <option value="1">普通团长</option>
              <option value="2">高级团长</option>
              <option value="3">大团团长</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">代理层级</label>
            <select id="agentLevel" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent">
              <option value="">全部</option>
              <option value="1">一级代理</option>
              <option value="2">二级代理</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">统计周期</label>
            <select id="days" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent">
              <option value="0">全部</option>
              <option value="1">1天</option>
              <option value="7">7天</option>
              <option value="30">30天</option>
              <option value="365">12个月</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">排序字段</label>
            <select id="sortField" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent">
              <option value="created_at">创建时间</option>
              <option value="user_id">用户ID</option>
              <option value="username">用户名</option>
              <option value="is_agent">代理等级</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">排序方式</label>
            <select id="sortOrder" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent">
              <option value="desc">降序</option>
              <option value="asc">升序</option>
            </select>
          </div>
          <div class="flex items-end space-x-2">
            <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-all-300 flex items-center">
              <i class="fa fa-search mr-2"></i>
              查询
            </button>
            <button type="button" id="resetBtn" class="px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300 transition-all-300 flex items-center">
              <i class="fa fa-refresh mr-2"></i>
              重置
            </button>
          </div>
        </form>
      </div>

       <!-- 团队收益统计 -->
      <div class="p-6 border-b border-gray-200">
        <h2 class="text-lg font-semibold text-gray-800 mb-4 flex items-center">
          <i class="fa fa-line-chart mr-2 text-primary"></i>
          团队收益统计
        </h2>
        <div id="revenueStatisticsContainer" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <div class="bg-green-50 rounded-lg p-4 border border-green-100">
            <div class="text-sm text-green-600 font-medium mb-1">总收益</div>
            <div class="text-2xl font-bold text-green-700" id="totalRevenue">0.00</div>
          </div>
          <div class="bg-blue-50 rounded-lg p-4 border border-blue-100">
            <div class="text-sm text-blue-600 font-medium mb-1">一级代理收益</div>
            <div class="text-2xl font-bold text-blue-700" id="level1Revenue">0.00</div>
          </div>
          <div class="bg-purple-50 rounded-lg p-4 border border-purple-100">
            <div class="text-sm text-purple-600 font-medium mb-1">二级代理收益</div>
            <div class="text-2xl font-bold text-purple-700" id="level2Revenue">0.00</div>
          </div>
          <div class="bg-yellow-50 rounded-lg p-4 border border-yellow-100">
            <div class="text-sm text-yellow-600 font-medium mb-1">收益笔数</div>
            <div class="text-2xl font-bold text-yellow-700" id="revenueCount">0</div>
          </div>
        </div>
      </div>
      
      <!-- 统计信息 -->
      <div id="statisticsContainer" class="p-6 border-b border-gray-200">
        <h2 class="text-lg font-semibold text-gray-800 mb-4 flex items-center">
          <i class="fa fa-bar-chart mr-2 text-primary"></i>
          统计信息
        </h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
          <div class="bg-blue-50 rounded-lg p-4 border border-blue-100">
            <div class="text-sm text-blue-600 font-medium mb-1">总用户数</div>
            <div class="text-2xl font-bold text-blue-700" id="totalUsers">0</div>
          </div>
          <div class="bg-green-50 rounded-lg p-4 border border-green-100">
            <div class="text-sm text-green-600 font-medium mb-1">大团团长数量</div>
            <div class="text-2xl font-bold text-green-700" id="largeCaptains">0</div>
          </div>
          
          <div class="bg-indigo-50 rounded-lg p-4 border border-indigo-100">
            <div class="text-sm text-indigo-600 font-medium mb-1">普通用户数量</div>
            <div class="text-2xl font-bold text-indigo-700" id="normalUsers">0</div>
          </div>
        
          <div class="bg-teal-50 rounded-lg p-4 border border-teal-100">
            <div class="text-sm text-teal-600 font-medium mb-1">普通团长数量</div>
            <div class="text-2xl font-bold text-teal-700" id="normalCaptains">0</div>
          </div>
          <div class="bg-pink-50 rounded-lg p-4 border border-pink-100">
            <div class="text-sm text-pink-600 font-medium mb-1">高级团长数量</div>
            <div class="text-2xl font-bold text-pink-700" id="seniorCaptains">0</div>
          </div>
             <div class="bg-red-50 rounded-lg p-4 border border-red-100">
            <div class="text-sm text-red-600 font-medium mb-1">总下级数</div>
            <div class="text-2xl font-bold text-red-700" id="totalSubordinates">0</div>
          </div>
          <div class="bg-purple-50 rounded-lg p-4 border border-purple-100">
            <div class="text-sm text-purple-600 font-medium mb-1">一级代理数</div>
            <div class="text-2xl font-bold text-purple-700" id="level1Agents">0</div>
          </div>
          <div class="bg-yellow-50 rounded-lg p-4 border border-yellow-100">
            <div class="text-sm text-yellow-600 font-medium mb-1">二级代理数</div>
            <div class="text-2xl font-bold text-yellow-700" id="level2Agents">0</div>
          </div>
          <div class="bg-orange-50 rounded-lg p-4 border border-orange-100">
            <div class="text-sm text-orange-600 font-medium mb-1">直接下级数</div>
            <div class="text-2xl font-bold text-orange-700" id="directSubordinates">0</div>
          </div>
          <div class="bg-cyan-50 rounded-lg p-4 border border-cyan-100">
            <div class="text-sm text-cyan-600 font-medium mb-1">间接下级数</div>
            <div class="text-2xl font-bold text-cyan-700" id="indirectSubordinates">0</div>
          </div>
        </div>
      </div>
      
      
      <!-- 用户列表 -->
      <div class="p-6">
        <div class="flex justify-between items-center mb-4">
          <h2 class="text-lg font-semibold text-gray-800 flex items-center">
            <i class="fa fa-list mr-2 text-primary"></i>
            用户列表
          </h2>
          <div class="flex items-center space-x-2">
            <label class="block text-sm font-medium text-gray-700">每页显示</label>
            <select id="limit" class="px-2 py-1 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent">
              <option value="10">10条</option>
              <option value="20">20条</option>
              <option value="50" selected>50条</option>
              <option value="100">100条</option>
            </select>
          </div>
        </div>
        
        <div id="usersContainer" class="overflow-x-auto">
          <table class="w-full min-w-[1000px] divide-y divide-gray-200">
            <thead class="bg-gray-50 sticky top-0">
              <tr>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">用户ID</th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">用户名</th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">手机号</th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">当前用户代理等级</th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">直接上级</th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">间接上级</th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">直接下级</th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">间接下级</th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">总下级</th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">创建时间</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200" id="usersTableBody">
              <!-- 用户数据将在这里渲染 -->
              <tr>
                <td colspan="10" class="px-6 py-12 text-center text-gray-500">
                  <i class="fa fa-spinner fa-spin mr-2"></i>
                  加载中...
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        
        <!-- 分页 -->
        <div id="pagination" class="flex items-center justify-between mt-6">
          <div class="text-sm text-gray-500" id="paginationInfo">
            共 0 条记录，共 0 页
          </div>
          <div class="flex items-center space-x-2" id="paginationLinks">
            <!-- 分页链接将在这里渲染 -->
          </div>
        </div>
      </div>
    </div>
  `;
}

/**
 * 初始化团队收益页面
 * 在页面加载完成后执行必要的初始化操作
 */
function initTeamRevenuePage() {
  // 全局变量
  window.currentPage = 1;
  window.token = getToken();
  
  // 加载数据
  loadUsers();
  loadRevenueStatistics();
  
  // 表单提交事件
  const searchForm = document.getElementById('searchForm');
  if (searchForm) {
    searchForm.addEventListener('submit', function(e) {
      e.preventDefault();
      window.currentPage = 1;
      loadUsers();
      loadRevenueStatistics();
    });
  }
  
  // 重置按钮事件
  const resetBtn = document.getElementById('resetBtn');
  if (resetBtn) {
    resetBtn.addEventListener('click', function() {
      document.getElementById('userId').value = '';
      document.getElementById('username').value = '';
      document.getElementById('isAgent').value = '';
      document.getElementById('agentLevel').value = '';
      document.getElementById('days').value = '0';
      document.getElementById('sortField').value = 'created_at';
      document.getElementById('sortOrder').value = 'asc';
      document.getElementById('limit').value = '50';
      window.currentPage = 1;
      loadUsers();
      loadRevenueStatistics();
    });
  }
  
  // 每页显示条数变化事件
  const limitSelect = document.getElementById('limit');
  if (limitSelect) {
    limitSelect.addEventListener('change', function() {
      window.currentPage = 1;
      loadUsers();
    });
  }
}

/**
 * 加载用户数据
 */
async function loadUsers() {
  // 显示加载状态
  const tableBody = document.getElementById('usersTableBody');
  if (tableBody) {
    tableBody.innerHTML = `
      <tr>
        <td colspan="10" class="px-6 py-12 text-center text-gray-500">
          <i class="fa fa-spinner fa-spin mr-2"></i>
          加载中...
        </td>
      </tr>
    `;
  }
  
  // 获取查询参数
  const params = new URLSearchParams();
  params.append('page', window.currentPage);
  params.append('limit', document.getElementById('limit').value);
  params.append('user_id', document.getElementById('userId').value);
  params.append('username', document.getElementById('username').value);
  params.append('is_agent', document.getElementById('isAgent').value);
  params.append('agent_level', document.getElementById('agentLevel').value);
  params.append('days', document.getElementById('days').value);
  params.append('sort_field', document.getElementById('sortField').value);
  params.append('sort_order', document.getElementById('sortOrder').value);
  
  try {
    // 发送API请求
    const token = getToken();
    const headers = {
      'Content-Type': 'application/json'
    };
    
    if (token) {
      headers['X-token'] = token;
    }
    
    const response = await fetch(`api/team_revenue/team_users.php?${params.toString()}`, {
      headers: headers,
      credentials: 'include'
    });
    
    if (response.status === 401) {
      console.log('未授权，跳转到登录页');
      sessionStorage.clear();
      localStorage.removeItem('admin_current_page');
      fetch('/task_admin/auth/logout.php', { method: 'POST' }).catch(err => {});
      window.location.href = '/task_admin/login.html';
      return;
    }
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    
    if (data.code === 0) {
      // 更新统计信息
      updateStatistics(data.data.statistics);
      
      // 渲染用户列表
      renderUsers(data.data.list);
      
      // 渲染分页
      renderPagination(data.data);
    } else {
      // 显示错误信息
      if (tableBody) {
        tableBody.innerHTML = `
          <tr>
            <td colspan="10" class="px-6 py-12 text-center text-red-500">
              <i class="fa fa-exclamation-circle mr-2"></i>
              ${data.message || '获取数据失败'}
            </td>
          </tr>
        `;
      }
    }
  } catch (error) {
    // 显示错误信息
    if (tableBody) {
      tableBody.innerHTML = `
        <tr>
          <td colspan="10" class="px-6 py-12 text-center text-red-500">
            <i class="fa fa-exclamation-circle mr-2"></i>
            网络错误，请稍后重试
          </td>
        </tr>
      `;
    }
    console.error('Error:', error);
  }
}

/**
 * 更新统计信息
 * @param {Object} statistics - 统计数据
 */
function updateStatistics(statistics) {
  if (!statistics) return;
  
  // 更新总用户数
  const totalUsersElement = document.getElementById('totalUsers');
  if (totalUsersElement) {
    totalUsersElement.textContent = statistics.total_users || 0;
  }
  
  // 更新普通用户数量
  const normalUsersElement = document.getElementById('normalUsers');
  if (normalUsersElement) {
    normalUsersElement.textContent = statistics.normal_users || 0;
  }
  
  // 更新普通团长数量
  const normalCaptainsElement = document.getElementById('normalCaptains');
  if (normalCaptainsElement) {
    normalCaptainsElement.textContent = statistics.normal_captains || 0;
  }
  
  // 更新高级团长数量
  const seniorCaptainsElement = document.getElementById('seniorCaptains');
  if (seniorCaptainsElement) {
    seniorCaptainsElement.textContent = statistics.senior_captains || 0;
  }
  
  // 更新大团团长数量
  const largeCaptainsElement = document.getElementById('largeCaptains');
  if (largeCaptainsElement) {
    largeCaptainsElement.textContent = statistics.large_captains || 0;
  }
  
  // 更新一级代理数
  const level1AgentsElement = document.getElementById('level1Agents');
  if (level1AgentsElement) {
    level1AgentsElement.textContent = statistics.level1_agents || 0;
  }
  
  // 更新二级代理数
  const level2AgentsElement = document.getElementById('level2Agents');
  if (level2AgentsElement) {
    level2AgentsElement.textContent = statistics.level2_agents || 0;
  }
  
  // 更新总下级数
  const totalSubordinatesElement = document.getElementById('totalSubordinates');
  if (totalSubordinatesElement) {
    totalSubordinatesElement.textContent = statistics.total_subordinates || 0;
  }
  
  // 更新直接下级数
  const directSubordinatesElement = document.getElementById('directSubordinates');
  if (directSubordinatesElement) {
    directSubordinatesElement.textContent = statistics.direct_subordinates || 0;
  }
  
  // 更新间接下级数
  const indirectSubordinatesElement = document.getElementById('indirectSubordinates');
  if (indirectSubordinatesElement) {
    indirectSubordinatesElement.textContent = statistics.indirect_subordinates || 0;
  }
}

/**
 * 渲染用户列表
 * @param {Array} users - 用户列表数据
 */
function renderUsers(users) {
  const tableBody = document.getElementById('usersTableBody');
  
  if (!tableBody) {
    console.error('团队用户列表容器不存在');
    return;
  }
  
  if (!users || users.length === 0) {
    tableBody.innerHTML = `
      <tr>
        <td colspan="10" class="px-6 py-12 text-center text-gray-500">
          <i class="fa fa-info-circle mr-2"></i>
          暂无数据
        </td>
      </tr>
    `;
    return;
  }
  
  let html = '';
  users.forEach(user => {
    // 直接上级
    const directSuperior = user.superiors && user.superiors.direct ? `${user.superiors.direct.username}(${user.superiors.direct.id})` : '-';
    
    // 间接上级
    const indirectSuperior = user.superiors && user.superiors.indirect ? `${user.superiors.indirect.username}(${user.superiors.indirect.id})` : '-';
    
    // 直接下级
    const directSubordinates = user.subordinates && user.subordinates.direct && user.subordinates.direct.length > 0 
      ? user.subordinates.direct.map(sub => `${sub.username}(${sub.id})`).join(', ') 
      : '-';
    
    // 间接下级
    const indirectSubordinates = user.subordinates && user.subordinates.indirect && user.subordinates.indirect.length > 0 
      ? user.subordinates.indirect.map(sub => `${sub.username}(${sub.id})`).join(', ') 
      : '-';
    
    // 代理等级样式
    let agentLevelClass = 'bg-gray-100 text-gray-800';
    if (user.is_agent === 1) {
      agentLevelClass = 'bg-blue-100 text-blue-800';
    } else if (user.is_agent === 2) {
      agentLevelClass = 'bg-green-100 text-green-800';
    } else if (user.is_agent === 3) {
      agentLevelClass = 'bg-purple-100 text-purple-800';
    }
    
    html += `
      <tr class="hover:bg-gray-50 transition-all-300">
        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">${user.id}</td>
        <td class="px-6 py-4 whitespace-nowrap">
          <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
            ${user.username}
          </span>
        </td>
        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${user.phone}</td>
        <td class="px-6 py-4 whitespace-nowrap">
          <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${agentLevelClass}">
            ${user.is_agent_text}
          </span>
        </td>
        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${directSuperior}</td>
        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${indirectSuperior}</td>
        <td class="px-6 py-4 text-sm text-gray-900">${directSubordinates}</td>
        <td class="px-6 py-4 text-sm text-gray-900">${indirectSubordinates}</td>
        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">${user.subordinate_counts ? user.subordinate_counts.total : 0}</td>
        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${user.created_at}</td>
      </tr>
    `;
  });
  
  tableBody.innerHTML = html;
}

/**
 * 渲染分页
 * @param {Object} data - 分页数据
 */
function renderPagination(data) {
  const paginationInfo = document.getElementById('paginationInfo');
  const paginationLinks = document.getElementById('paginationLinks');
  
  if (!paginationInfo || !paginationLinks) {
    return;
  }
  
  // 确保数据完整性
  const total = data.total || 0;
  const lastPage = data.last_page || 1;
  
  // 更新分页信息
  paginationInfo.textContent = `共 ${total} 条记录，共 ${lastPage} 页`;
  
  // 渲染分页链接
  let html = '';
  
  // 首页按钮
  html += `
    <button ${window.currentPage === 1 ? 'disabled' : ''} onclick="window.currentPage = 1; loadUsers();" 
      class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-all-300">
      <i class="fa fa-angle-double-left"></i>
    </button>
  `;
  
  // 上一页按钮
  html += `
    <button ${window.currentPage === 1 ? 'disabled' : ''} onclick="window.currentPage = Math.max(1, window.currentPage - 1); loadUsers();" 
      class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-all-300">
      <i class="fa fa-angle-left"></i>
    </button>
  `;
  
  // 页码按钮
  const startPage = Math.max(1, window.currentPage - 2);
  const endPage = Math.min(lastPage, startPage + 4);
  
  for (let i = startPage; i <= endPage; i++) {
    html += `
      <button ${i === window.currentPage ? 'disabled' : ''} onclick="window.currentPage = ${i}; loadUsers();" 
        class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium ${i === window.currentPage ? 'text-gray-700 bg-white hover:bg-gray-50' : 'text-gray-700 bg-white hover:bg-gray-50'} disabled:opacity-50 disabled:cursor-not-allowed transition-all-300">
        ${i}
      </button>
    `;
  }
  
  // 下一页按钮
  html += `
    <button ${window.currentPage >= lastPage ? 'disabled' : ''} onclick="window.currentPage = Math.min(${lastPage}, window.currentPage + 1); loadUsers();" 
      class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-all-300">
      <i class="fa fa-angle-right"></i>
    </button>
  `;
  
  // 末页按钮
  html += `
    <button ${window.currentPage >= lastPage ? 'disabled' : ''} onclick="window.currentPage = ${lastPage}; loadUsers();" 
      class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-all-300">
      <i class="fa fa-angle-double-right"></i>
    </button>
  `;
  
  paginationLinks.innerHTML = html;
}

/**
 * 加载团队收益统计
 */
async function loadRevenueStatistics() {
  // 获取查询参数
  const params = new URLSearchParams();
  params.append('user_id', document.getElementById('userId').value);
  params.append('username', document.getElementById('username').value);
  params.append('days', document.getElementById('days').value);
  params.append('is_agent', document.getElementById('isAgent').value);
  params.append('agent_level', document.getElementById('agentLevel').value);
  
  
  try {
    // 发送API请求到statistics.php
    const token = getToken();
    const headers = {
      'Content-Type': 'application/json'
    };
    
    if (token) {
      headers['X-token'] = token;
    }
    
    const response = await fetch(`api/team_revenue/statistics.php?${params.toString()}`, {
      headers: headers,
      credentials: 'include'
    });
    
    if (response.status === 401) {
      console.log('未授权，跳转到登录页');
      sessionStorage.clear();
      localStorage.removeItem('admin_current_page');
      fetch('/task_admin/auth/logout.php', { method: 'POST' }).catch(err => {});
      window.location.href = '/task_admin/login.html';
      return;
    }
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    console.log('获取到的统计数据',data)
    if (data.code === 0 && data.data) {
      // 计算总收益
      let totalRevenue = 0;
      let level1Revenue = 0;
      let level2Revenue = 0;
      let totalCount = 0;
      
      if (data.data.list && data.data.list.length > 0) {
        data.data.list.forEach(item => {
          totalRevenue += parseFloat(item.team_revenue.total) || 0;
          level1Revenue += parseFloat(item.team_revenue.level1) || 0;
          level2Revenue += parseFloat(item.team_revenue.level2) || 0;
          totalCount += (item.revenue_stats.task_count || 0) + (item.revenue_stats.order_count || 0);
        });
      }
      
      // 更新收益统计信息
      const totalRevenueElement = document.getElementById('totalRevenue');
      if (totalRevenueElement) {
        totalRevenueElement.textContent = totalRevenue.toFixed(2);
        
      }
      
      const level1RevenueElement = document.getElementById('level1Revenue');
      if (level1RevenueElement) {
        level1RevenueElement.textContent = level1Revenue.toFixed(2);
      }
      
      const level2RevenueElement = document.getElementById('level2Revenue');
      if (level2RevenueElement) {
        level2RevenueElement.textContent = level2Revenue.toFixed(2);
      }
      
      // 更新收益笔数
      const revenueCountElement = document.getElementById('revenueCount');
      if (revenueCountElement) {
        revenueCountElement.textContent = totalCount;
      }
     
      
    }
  } catch (error) {
    console.error('Error loading revenue statistics:', error);
  }
}

/**
 * 获取Token
 * @returns {string} Token值
 */
function getToken() {
  // 从sessionStorage中获取Token
  return sessionStorage.getItem('admin_token') || '';
}

/**
 * 初始化团队收益详情页面
 */
function loadTeamRevenueDetails() {
  // 这里可以添加团队收益详情页面的加载逻辑
  console.log('加载团队收益详情页面');
}

/**
 * 初始化团队收益表单
 */
function initTeamRevenueForm() {
  // 表单初始化逻辑已在initTeamRevenuePage中处理
}

/**
 * 初始化团队收益详情表单
 */
function initTeamRevenueDetailsForm() {
  // 这里可以添加团队收益详情表单的初始化逻辑
}

// 导出函数供外部使用
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    loadTeamRevenue,
    loadTeamRevenueDetails,
    initTeamRevenueForm,
    initTeamRevenueDetailsForm
  };
}
