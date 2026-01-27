import type { IconName } from "./icons.js";

export const TAB_GROUPS = [
  { label: "聊天", tabs: ["chat"] },
  {
    label: "控制台",
    tabs: ["overview", "channels", "instances", "sessions", "cron"],
  },
  { label: "代理", tabs: ["skills", "nodes"] },
  { label: "设置", tabs: ["config", "debug", "logs"] },
] as const;

export type Tab =
  | "overview"
  | "channels"
  | "instances"
  | "sessions"
  | "cron"
  | "skills"
  | "nodes"
  | "chat"
  | "config"
  | "debug"
  | "logs";

const TAB_PATHS: Record<Tab, string> = {
  overview: "/overview",
  channels: "/channels",
  instances: "/instances",
  sessions: "/sessions",
  cron: "/cron",
  skills: "/skills",
  nodes: "/nodes",
  chat: "/chat",
  config: "/config",
  debug: "/debug",
  logs: "/logs",
};

const PATH_TO_TAB = new Map(
  Object.entries(TAB_PATHS).map(([tab, path]) => [path, tab as Tab]),
);

export function normalizeBasePath(basePath: string): string {
  if (!basePath) return "";
  let base = basePath.trim();
  if (!base.startsWith("/")) base = `/${base}`;
  if (base === "/") return "";
  if (base.endsWith("/")) base = base.slice(0, -1);
  return base;
}

export function normalizePath(path: string): string {
  if (!path) return "/";
  let normalized = path.trim();
  if (!normalized.startsWith("/")) normalized = `/${normalized}`;
  if (normalized.length > 1 && normalized.endsWith("/")) {
    normalized = normalized.slice(0, -1);
  }
  return normalized;
}

export function pathForTab(tab: Tab, basePath = ""): string {
  const base = normalizeBasePath(basePath);
  const path = TAB_PATHS[tab];
  return base ? `${base}${path}` : path;
}

export function tabFromPath(pathname: string, basePath = ""): Tab | null {
  const base = normalizeBasePath(basePath);
  let path = pathname || "/";
  if (base) {
    if (path === base) {
      path = "/";
    } else if (path.startsWith(`${base}/`)) {
      path = path.slice(base.length);
    }
  }
  let normalized = normalizePath(path).toLowerCase();
  if (normalized.endsWith("/index.html")) normalized = "/";
  if (normalized === "/") return "chat";
  return PATH_TO_TAB.get(normalized) ?? null;
}

export function inferBasePathFromPathname(pathname: string): string {
  let normalized = normalizePath(pathname);
  if (normalized.endsWith("/index.html")) {
    normalized = normalizePath(normalized.slice(0, -"/index.html".length));
  }
  if (normalized === "/") return "";
  const segments = normalized.split("/").filter(Boolean);
  if (segments.length === 0) return "";
  for (let i = 0; i < segments.length; i++) {
    const candidate = `/${segments.slice(i).join("/")}`.toLowerCase();
    if (PATH_TO_TAB.has(candidate)) {
      const prefix = segments.slice(0, i);
      return prefix.length ? `/${prefix.join("/")}` : "";
    }
  }
  return `/${segments.join("/")}`;
}

export function iconForTab(tab: Tab): IconName {
  switch (tab) {
    case "chat":
      return "messageSquare";
    case "overview":
      return "barChart";
    case "channels":
      return "link";
    case "instances":
      return "radio";
    case "sessions":
      return "fileText";
    case "cron":
      return "loader";
    case "skills":
      return "zap";
    case "nodes":
      return "monitor";
    case "config":
      return "settings";
    case "debug":
      return "bug";
    case "logs":
      return "scrollText";
    default:
      return "folder";
  }
}

export function titleForTab(tab: Tab) {
  switch (tab) {
    case "overview":
      return "概览";
    case "channels":
      return "频道";
    case "instances":
      return "实例";
    case "sessions":
      return "会话";
    case "cron":
      return "定时任务";
    case "skills":
      return "技能";
    case "nodes":
      return "节点";
    case "chat":
      return "聊天";
    case "config":
      return "配置";
    case "debug":
      return "调试";
    case "logs":
      return "日志";
    default:
      return "控制台";
  }
}

export function subtitleForTab(tab: Tab) {
  switch (tab) {
    case "overview":
      return "网关状态、入口端点和快速健康检查。";
    case "channels":
      return "管理消息频道和相关设置。";
    case "instances":
      return "已连接客户端和节点的存在信标。";
    case "sessions":
      return "查看活跃会话并调整会话默认设置。";
    case "cron":
      return "调度唤醒和定期代理运行任务。";
    case "skills":
      return "管理技能可用性和 API 密钥注入。";
    case "nodes":
      return "已配对设备、能力和命令暴露。";
    case "chat":
      return "直接与网关聊天，用于快速交互。";
    case "config":
      return "安全编辑 ~/.clawdbot/clawdbot.json 配置文件。";
    case "debug":
      return "网关快照、事件和手动 RPC 调用。";
    case "logs":
      return "实时查看网关日志文件。";
    default:
      return "";
  }
}
