import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

export const list = query({
  args: {},
  returns: v.array(
    v.object({
      _id: v.id("todos"),
      _creationTime: v.number(),
      text: v.string(),
      createdAt: v.number(),
    }),
  ),
  handler: async (ctx) => {
    return await ctx.db.query("todos").withIndex("by_createdAt").collect();
  },
});

export const create = mutation({
  args: {},
  returns: v.null(),
  handler: async (ctx) => {
    await ctx.db.insert("todos", {
      text: "Todo",
      createdAt: Date.now(),
    });
    return null;
  },
});

export const remove = mutation({
  args: {
    id: v.id("todos"),
  },
  returns: v.null(),
  handler: async (ctx, args) => {
    await ctx.db.delete(args.id);
    return null;
  },
});
