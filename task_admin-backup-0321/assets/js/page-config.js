/**
 * 页面配置管理模块
 * 集中管理所有页面的配置信息，包括页面路由、section ID、数据加载函数等
 * 目的是简化页面切换逻辑，减少硬编码，提高可维护性
 */

/**
 * 页面配置对象
 * 键: 页面代码 (与数据库system_permission_template表的code字段对应)
 * 值: 页面配置信息
 */
const pageConfig = {
  // 仪表板
  'dashboard': {
    /**
     * 页面对应的section ID (与HTML中的section元素ID对应)
     */
    sectionId: 'dashboardSection',
    /**
     * 数据加载函数名 (全局函数)
     */
    loadFunction: 'loadDashboard'
  },
  
  // B端用户
  'b-users': {
    sectionId: 'b-usersSection',
    loadFunction: 'loadBUsers'
  },
  
  // B端交易流水
  'b-statistics-flows': {
    sectionId: 'b-statisticsSection',
    loadFunction: 'loadBStatistics'
  },
  
  // B端数据统计
  'b-statistics-summary': {
    sectionId: 'b-statisticsSection',
    loadFunction: 'loadOrderStatistics'
  },
  
  // C端用户
  'c-users': {
    sectionId: 'c-usersSection',
    loadFunction: 'loadCUsers'
  },
  
  // C端交易流水
  'c-statistics-flows': {
    sectionId: 'c-statisticsSection',
    loadFunction: 'loadCStatistics'
  },
  
  // C端数据统计
  'c-statistics-summary': {
    sectionId: 'c-statisticsSection',
    loadFunction: 'loadCOrderStatistics'
  },
  
  // 系统用户
  'system-users': {
    sectionId: 'system-usersSection',
    loadFunction: 'loadSystemUsers'
  },
  
  // 角色管理
  'system-roles': {
    sectionId: 'system-rolesSection',
    loadFunction: 'loadSystemRoles'
  },
  
  // 权限管理
  'system-permissions': {
    sectionId: 'system-permissionsSection',
    loadFunction: 'loadSystemPermissions'
  },
  
  // 任务模板
  'templates': {
    sectionId: 'templatesSection',
    loadFunction: 'loadTaskTemplates'
  },
  
  // 任务市场
  'market': {
    sectionId: 'marketSection',
    loadFunction: 'loadMarketTasks'
  },
  
  // 钱包记录
  'wallet-logs': {
    sectionId: 'wallet-logsSection',
    loadFunction: 'loadWalletLogs'
  },
  
  // 充值审核
  'recharge': {
    sectionId: 'rechargeSection',
    loadFunction: 'loadRechargeList'
  },
  
  // 提现审核
  'withdraw': {
    sectionId: 'withdrawSection',
    loadFunction: 'loadWithdrawList'
  },
  
  // 团长审核
  'agent': {
    sectionId: 'agentSection',
    loadFunction: 'loadAgentList'
  },
  
  // 团长迁跃升级
  'agent-upgrade': {
    sectionId: 'agentUpgradeSection',
    loadFunction: 'loadCUsersForUpgrade'
  },
  
  // 租赁处理
  'rental-orders': {
    sectionId: 'rental-ordersSection',
    loadFunction: 'loadRentalOrders'
  },
  
  // 工单管理
  'rental-tickets': {
    sectionId: 'rental-ticketsSection',
    loadFunction: 'loadTickets'
  },
  
  // 网站配置
  'system-config': {
    sectionId: 'system-configSection',
    loadFunction: 'loadSystemConfig'
  },
  
  // 任务审核
  'task-review': {
    sectionId: 'task-reviewSection',
    loadFunction: 'loadTaskReviewList'
  },
  
  // 系统通知
  'notifications': {
    sectionId: 'notificationsSection',
    loadFunction: 'loadNotificationList'
  },
  
  // 提示通知列表
  'notification-logs': {
    sectionId: 'notification-logsSection',
    /**
     * 数据加载函数 (直接定义函数，适用于需要多个操作的情况)
     */
    loadFunction: function() {
      loadNotifications(1, '', '0');
      loadNotificationLogs();
    }
  },
  
  // 放大镜任务
  'magnifier': {
    sectionId: 'magnifierSection',
    loadFunction: 'loadMagnifierTasks'
  },
  
  // 派单数据统计
  'order-statistics': {
    sectionId: 'b-statisticsSection',
    loadFunction: 'loadOrderStatistics'
  },
  
  // 团队收益概览
  'team-revenue-overview': {
    sectionId: 'team-revenueSection',
    loadFunction: 'loadTeamRevenue'
  },
  
  // 团队收益明细
  'team-revenue-details': {
    sectionId: 'team-revenueSection',
    loadFunction: 'loadTeamRevenueDetails'
  }
};

/**
 * 页面内容配置对象
 * 管理页面内部的内容区域和表单配置
 * 适用于一个section包含多个内容区域的情况
 */
const pageContentConfig = {
  // B端交易流水相关
  'b-statistics-flows': {
    /**
     * 内容区域ID (与HTML中的div元素ID对应)
     */
    contentId: 'b-statistics-flows-content',
    /**
     * 表单ID (与HTML中的form元素ID对应)
     */
    formId: 'bStatisticsForm',
    /**
     * 表单初始化函数名 (全局函数)
     */
    initFunction: 'initBStatisticsForm'
  },
  'b-statistics-summary': {
    contentId: 'b-statistics-summary-content',
    formId: 'orderStatisticsForm',
    initFunction: 'initOrderStatisticsForm'
  },
  
  // C端交易流水相关
  'c-statistics-flows': {
    contentId: 'c-statistics-flows-content',
    formId: 'cStatisticsForm',
    initFunction: 'initCStatisticsForm'
  },
  'c-statistics-summary': {
    contentId: 'c-statistics-summary-content',
    formId: 'cOrderStatisticsForm',
    initFunction: 'initCOrderStatisticsForm'
  },
  
  // 团队收益相关
  'team-revenue-overview': {
    contentId: 'team-revenue-content',
    formId: 'teamRevenueForm',
    initFunction: 'initTeamRevenueForm',
    listContainerId: 'teamListContainer'
  },
  'team-revenue-details': {
    contentId: 'team-revenue-details-content',
    formId: 'teamRevenueDetailsForm',
    initFunction: 'initTeamRevenueDetailsForm'
  }
};

/**
 * 获取页面配置
 * @param {string} page - 页面代码
 * @returns {Object|null} 页面配置对象
 */
export function getPageConfig(page) {
  return pageConfig[page];
}

/**
 * 获取页面内容配置
 * @param {string} page - 页面代码
 * @returns {Object|null} 页面内容配置对象
 */
export function getPageContentConfig(page) {
  return pageContentConfig[page];
}

/**
 * 检查页面是否存在配置
 * @param {string} page - 页面代码
 * @returns {boolean} 是否存在配置
 */
export function hasPageConfig(page) {
  return page in pageConfig;
}

/**
 * 检查页面内容是否存在配置
 * @param {string} page - 页面代码
 * @returns {boolean} 是否存在配置
 */
export function hasPageContentConfig(page) {
  return page in pageContentConfig;
}

/**
 * 新增页面配置
 * @param {string} page - 页面代码
 * @param {Object} config - 页面配置对象
 */
export function addPageConfig(page, config) {
  pageConfig[page] = config;
}

/**
 * 新增页面内容配置
 * @param {string} page - 页面代码
 * @param {Object} config - 页面内容配置对象
 */
export function addPageContentConfig(page, config) {
  pageContentConfig[page] = config;
}

/**
 * 导出配置对象
 * 用于外部访问完整的配置信息
 */
export { pageConfig, pageContentConfig };