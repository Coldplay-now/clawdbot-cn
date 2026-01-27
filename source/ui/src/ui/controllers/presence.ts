import type { GatewayBrowserClient } from "../gateway";
import type { PresenceEntry } from "../types";

export type PresenceState = {
  client: GatewayBrowserClient | null;
  connected: boolean;
  presenceLoading: boolean;
  presenceEntries: PresenceEntry[];
  presenceError: string | null;
  presenceStatus: string | null;
};

export async function loadPresence(state: PresenceState) {
  if (!state.client || !state.connected) return;
  if (state.presenceLoading) return;
  state.presenceLoading = true;
  state.presenceError = null;
  state.presenceStatus = null;
  try {
    const res = (await state.client.request("system-presence", {})) as
      | PresenceEntry[]
      | undefined;
    if (Array.isArray(res)) {
      state.presenceEntries = res;
      state.presenceStatus = res.length === 0 ? "暂无实例。" : null;
    } else {
      state.presenceEntries = [];
      state.presenceStatus = "无存在数据。";
    }
  } catch (err) {
    state.presenceError = String(err);
  } finally {
    state.presenceLoading = false;
  }
}
