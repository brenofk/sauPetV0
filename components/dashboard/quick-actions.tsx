"use client"

import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Plus, Syringe } from "lucide-react"
import { useRouter } from "next/navigation"

export function QuickActions() {
  const router = useRouter()

  return (
    <Card>
      <CardContent className="p-4">
        <h2 className="text-lg font-semibold mb-4">Ações Rápidas</h2>
        <div className="grid grid-cols-2 gap-3">
          <Button
            variant="outline"
            className="h-20 flex-col space-y-2 bg-primary/5 border-primary/20 hover:bg-primary/10"
            onClick={() => router.push("/pets/new")}
          >
            <Plus className="w-6 h-6 text-primary" />
            <span className="text-sm font-medium">Adicionar Pet</span>
          </Button>

          <Button
            variant="outline"
            className="h-20 flex-col space-y-2 bg-secondary/5 border-secondary/20 hover:bg-secondary/10"
            onClick={() => router.push("/vaccines/new")}
          >
            <Syringe className="w-6 h-6 text-secondary" />
            <span className="text-sm font-medium">Nova Vacina</span>
          </Button>
        </div>
      </CardContent>
    </Card>
  )
}
